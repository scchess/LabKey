package org.labkey.sequenceanalysis.run.util;

import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.sequenceanalysis.pipeline.SequencePipelineService;
import org.labkey.api.sequenceanalysis.run.AbstractCommandWrapper;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by bimber on 9/2/2014.
 */
public class BgzipRunner extends AbstractCommandWrapper
{
    public BgzipRunner(@Nullable Logger logger)
    {
        super(logger);
    }

    public File execute(File input) throws PipelineJobException
    {
        getLogger().info("BGZipping file: " + input.getPath());

        execute(getParams(input));
        File output = new File(input.getPath() + ".gz");
        if (!output.exists())
            throw new PipelineJobException("Output not created, expected: " + output.getPath());

        if (input.exists())
        {
            getLogger().debug("deleting input: " + input.getPath());
            input.delete();
        }

        return output;
    }

    public List<String> getParams(File input)
    {
        List<String> params = new ArrayList<>();
        params.add(getExe().getPath());
        params.add("-f");

        params.add(input.getPath());

        return params;
    }

    public File getExe()
    {
        return SequencePipelineService.get().getExeForPackage("BGZIPPATH", "bgzip");
    }
}
