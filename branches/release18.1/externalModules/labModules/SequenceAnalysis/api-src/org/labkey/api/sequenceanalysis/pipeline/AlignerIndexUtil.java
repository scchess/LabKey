package org.labkey.api.sequenceanalysis.pipeline;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.ConvertHelper;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.WorkDirectory;
import org.labkey.api.sequenceanalysis.run.SimpleScriptWrapper;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

/**
 * Created by bimber on 9/6/2014.
 */
public class AlignerIndexUtil
{
    public static final String INDEX_DIR = "alignerIndexes";
    public static final String COPY_LOCALLY = "copyGenomeLocally";

    public static boolean hasCachedIndex(PipelineContext ctx, String name, ReferenceGenome genome) throws PipelineJobException
    {
        ctx.getLogger().debug("checking whether cached index exists: " + name);

        return verifyOrCreateCachedIndex(ctx, null, null, name, name, genome, false);
    }

    public static boolean copyIndexIfExists(PipelineContext ctx, AlignmentOutputImpl output, String name, ReferenceGenome genome) throws PipelineJobException
    {
        return copyIndexIfExists(ctx, output, name, name, genome);
    }

    public static boolean copyIndexIfExists(PipelineContext ctx, AlignmentOutputImpl output, String localName, String webserverName, ReferenceGenome genome) throws PipelineJobException
    {
        return copyIndexIfExists(ctx, output, localName, webserverName, genome, false);
    }

    public static boolean copyIndexIfExists(PipelineContext ctx, AlignmentOutputImpl output, String localName, String webserverName, ReferenceGenome genome, boolean forceCopyLocal) throws PipelineJobException
    {
        ctx.getLogger().debug("copying index to shared dir if exists: " + localName);
        if (ctx.getWorkDir() == null)
        {
            throw new PipelineJobException("PipelineContext.getWorkDir() is null");
        }

        return verifyOrCreateCachedIndex(ctx, ctx.getWorkDir(), output, localName, webserverName, genome, forceCopyLocal);
    }

    public static File getWebserverIndexDir(ReferenceGenome genome, String name)
    {
        return new File(genome.getSourceFastaFile().getParentFile(), (genome.getGenomeId() == null ? "" : INDEX_DIR + "/") + name);
    }

    /**
     * If WorkDirectory is null, files will not be copied.  Otherwise files be be copied to this destination.
     */
    private static boolean verifyOrCreateCachedIndex(PipelineContext ctx, @Nullable WorkDirectory wd, @Nullable AlignmentOutputImpl output, String localName, String webserverName, ReferenceGenome genome, boolean forceCopyLocal) throws PipelineJobException
    {
        boolean hasCachedIndex = false;
        if (genome != null)
        {
            //NOTE: when we cache the indexes with the source FASTA genome, we store all aligners under the folder /alignerIndexes.  When these are temporary genomes, they're top-level
            File webserverIndexDir = getWebserverIndexDir(genome, webserverName);
            if (webserverIndexDir.exists())
            {
                ctx.getLogger().info("previously created index found, no need to recreate");
                ctx.getLogger().debug(webserverIndexDir.getPath());
                hasCachedIndex = true;

                try
                {
                    if (wd != null)
                    {
                        String val = ctx.getJob().getParameters().get(COPY_LOCALLY);
                        boolean doCopy = forceCopyLocal || (val == null ? true : ConvertHelper.convert(val, Boolean.class));

                        if (doCopy)
                        {
                            ctx.getLogger().info("copying index files to work location");
                            File localSharedDir = new File(wd.getDir(), "Shared");
                            File destination = new File(localSharedDir, localName);
                            ctx.getLogger().debug(destination.getPath());
                            File[] files = webserverIndexDir.listFiles();
                            if (files == null)
                            {
                                return false;
                            }

                            destination = wd.inputFile(webserverIndexDir, destination, true);
                            if (output != null && !destination.equals(webserverIndexDir))
                                output.addDeferredDeleteIntermediateFile(destination);

                            ctx.getLogger().info("finished copying files");
                        }
                        else
                        {
                            ctx.getLogger().debug("index files will not be copied to the work directory");
                        }
                    }
                    else
                    {
                        ctx.getLogger().info("no need to copy files at this time");
                    }
                }
                catch (IOException e)
                {
                    throw new PipelineJobException(e);
                }
            }
            else
            {
                ctx.getLogger().debug("expected location of cached index does not exist: " + webserverIndexDir.getPath());
            }
        }
        else
        {
            ctx.getLogger().debug("there is no cached reference genome, cannot build index");
        }

        return hasCachedIndex;
    }

    public static void saveCachedIndex(boolean hasCachedIndex, PipelineContext ctx, File indexDir, String name, ReferenceGenome genome) throws PipelineJobException
    {
        if (!hasCachedIndex && genome != null && genome.getGenomeId() != null)
        {
            File cachingDir = new File(genome.getSourceFastaFile().getParentFile(), INDEX_DIR + "/" + name);
            ctx.getLogger().info("caching index files for future use");
            ctx.getLogger().debug(cachingDir.getPath());

            try
            {
                if (!cachingDir.exists())
                {
                    cachingDir.mkdirs();
                }

                File[] files = indexDir.listFiles();
                for (File f : files)
                {
                    File dest = new File(cachingDir, f.getName());
                    if (f.equals(dest))
                    {
                        ctx.getLogger().debug("source/destination are the same, skipping: " + dest.getName());
                        continue;
                    }

                    ctx.getLogger().debug("copying file: " + dest.getName());
                    if (f.isDirectory())
                    {
                        FileUtils.copyDirectory(f, dest);
                    }
                    else
                    {
                        FileUtils.copyFile(f, dest);
                    }
                }
            }
            catch (IOException e)
            {
                throw new PipelineJobException(e);
            }
        }
    }

    public static void cacheGenomeLocally(ReferenceGenome genome, File localCacheDir, Logger log) throws PipelineJobException
    {
        log.info("attempting to rsync genome to local disks: " + localCacheDir.getPath());
        if (genome.getGenomeId() == null)
        {
            log.info("cannot cache custom genomes, skipping");
            return;
        }

        File sourceDir = genome.getSourceFastaFile().getParentFile();

        new SimpleScriptWrapper(log).execute(Arrays.asList(
                "rsync", "-r", "-vi", "-a", "--delete", "--delete-excluded", "--exclude", "tracks/*", "--exclude", "chainFiles/*", "--no-owner", "--no-group", sourceDir.getPath(), localCacheDir.getPath()
        ));

        genome.setWorkingFasta(new File(new File(localCacheDir, genome.getGenomeId().toString()), genome.getSourceFastaFile().getName()));
    }
}
