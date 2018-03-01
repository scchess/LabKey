package org.labkey.sequenceanalysis.run.variant;

import au.com.bytecode.opencsv.CSVWriter;
import htsjdk.samtools.util.CloseableIterator;
import htsjdk.variant.variantcontext.Genotype;
import htsjdk.variant.variantcontext.VariantContext;
import htsjdk.variant.vcf.VCFFileReader;
import org.json.JSONObject;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.sequenceanalysis.SequenceAnalysisService;
import org.labkey.api.sequenceanalysis.pipeline.AbstractVariantProcessingStepProvider;
import org.labkey.api.sequenceanalysis.pipeline.PipelineContext;
import org.labkey.api.sequenceanalysis.pipeline.PipelineStepProvider;
import org.labkey.api.sequenceanalysis.pipeline.ReferenceGenome;
import org.labkey.api.sequenceanalysis.pipeline.SequencePipelineService;
import org.labkey.api.sequenceanalysis.pipeline.ToolParameterDescriptor;
import org.labkey.api.sequenceanalysis.pipeline.VariantProcessingStep;
import org.labkey.api.sequenceanalysis.pipeline.VariantProcessingStepOutputImpl;
import org.labkey.api.sequenceanalysis.run.AbstractCommandPipelineStep;
import org.labkey.api.writer.PrintWriters;
import org.labkey.sequenceanalysis.pipeline.SequenceTaskHelper;
import org.labkey.sequenceanalysis.run.util.VariantAnnotatorWrapper;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by bimber on 4/26/2017.
 */
public class GenotypeConcordanceStep extends AbstractCommandPipelineStep<VariantAnnotatorWrapper> implements VariantProcessingStep
{
    public GenotypeConcordanceStep(PipelineStepProvider provider, PipelineContext ctx)
    {
        super(provider, ctx, new VariantAnnotatorWrapper(ctx.getLogger()));
    }

    public static class Provider extends AbstractVariantProcessingStepProvider<GenotypeConcordanceStep>
    {
        public Provider()
        {
            super("GenotypeConcordanceStep", "Annotate Genotype Concordance", "GATK", "Annotate genotypes relative to a reference VCF using a custom GATK Annotator", Arrays.asList(
                    ToolParameterDescriptor.createExpDataParam("refVCF", "Reference VCF", "This VCF will be used as the reference to annotate genotypes in the input VCF.  Genotypes that differ from this VCF will be annotated (but not filtered).  Genotypes not called in either VCF are skipped.", "ldk-expdatafield", new JSONObject(){{
                        put("allowBlank", false);
                    }}, null)
            ), Arrays.asList("ldk/field/ExpDataField.js"), "");
        }

        public GenotypeConcordanceStep create(PipelineContext ctx)
        {
            return new GenotypeConcordanceStep(this, ctx);
        }
    }

    @Override
    public Output processVariants(File inputVCF, File outputDirectory, ReferenceGenome genome) throws PipelineJobException
    {
        VariantProcessingStepOutputImpl output = new VariantProcessingStepOutputImpl();

        List<String> options = new ArrayList<>();

        File outputVcf = new File(outputDirectory, SequenceTaskHelper.getUnzippedBaseName(inputVCF) + ".annotated.vcf.gz");

        output.addInput(inputVCF, "Input VCF");

        options.add("-A");
        options.add("GenotypeConcordance");
        options.add("-A");
        options.add("GenotypeConcordanceBySite");

        Integer fileId = getProvider().getParameterByName("refVCF").extractValue(getPipelineCtx().getJob(), getProvider(), getStepIdx(), Integer.class);
        if (fileId == null)
        {
            throw new PipelineJobException("No reference VCF provided");
        }

        File refVCF = getPipelineCtx().getSequenceSupport().getCachedData(fileId);
        if (refVCF == null || !refVCF.exists())
        {
            throw new PipelineJobException("Reference VCF not found." + (refVCF == null ? "" : "  Path: " + refVCF.getPath()));
        }
        output.addInput(refVCF, "Reference VCF");

        options.add("-resource:GT_SOURCE");
        options.add(refVCF.getPath());

        Integer threads = SequencePipelineService.get().getMaxThreads(getPipelineCtx().getLogger());
        if (threads != null)
        {
            options.add("-nt");
            options.add(String.valueOf(Math.min(threads, 8)));
        }

        getWrapper().execute(genome.getWorkingFastaFile(), inputVCF, outputVcf, options);
        if (!outputVcf.exists())
        {
            throw new PipelineJobException("output not found: " + outputVcf);
        }

        output.setVcf(outputVcf);

        getPipelineCtx().getLogger().debug("writing summary report");
        File report = new File(outputDirectory, SequenceAnalysisService.get().getUnzippedBaseName(inputVCF.getName()) + "concordance.txt");
        try (CSVWriter writer = new CSVWriter(PrintWriters.getPrintWriter(report), '\t', CSVWriter.NO_QUOTE_CHARACTER); VCFFileReader reader = new VCFFileReader(outputVcf))
        {
            List<String> sampleNames = reader.getFileHeader().getSampleNamesInOrder();
            Map<String, DiscordantTracker> discordantMap = new HashMap<>();
            sampleNames.forEach(x -> discordantMap.put(x, new DiscordantTracker()));
            boolean loggedType = false;
            try (CloseableIterator<VariantContext> it = reader.iterator())
            {
                while (it.hasNext())
                {
                    VariantContext vc = it.next();
                    for (Genotype g : vc.getGenotypes())
                    {
                        DiscordantTracker t = discordantMap.get(g.getSampleName());
                        if (!g.isNoCall())
                        {
                            t.totalCalled += 1;
                        }

                        if (g.hasAnyAttribute("GTD") && g.getAnyAttribute("GTD") != null)
                        {
                            if (!loggedType)
                            {
                                getPipelineCtx().getLogger().debug("GTD attr class: " + g.getAnyAttribute("GTD").getClass());
                                loggedType = true;
                            }

                            int val = Integer.parseInt(g.getAnyAttribute("GTD").toString());
                            t.totalCompared += 1;
                            if (val == 1)
                            {
                                t.totalDiscordant += 1;
                            }
                        }
                    }
                }
            }

            writer.writeNext(new String[]{"SampleName", "TotalCalledGenotypes", "TotalComparedToRef", "TotalDiscordant", "FractionDiscordant"});
            for (String sn : sampleNames)
            {
                DiscordantTracker t = discordantMap.get(sn);
                writer.writeNext(new String[]{sn, String.valueOf(t.totalCalled), String.valueOf(t.totalCompared), String.valueOf(t.totalDiscordant), (t.totalCompared == 0 ? "" : String.valueOf(t.totalDiscordant / (double)t.totalCompared))});
            }
        }
        catch (IOException e)
        {
            throw new PipelineJobException(e);
        }

        output.addSequenceOutput(report, outputVcf.getName() + " genotype discordance report", "Genotype Discordance Report", null, null, genome.getGenomeId(), null);

        return output;
    }

    private class DiscordantTracker
    {
        long totalCompared = 0L;
        long totalDiscordant = 0L;
        long totalCalled = 0L;
    }
}
