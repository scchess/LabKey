package org.labkey.sequenceanalysis.pipeline;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.pipeline.AbstractTaskFactory;
import org.labkey.api.pipeline.AbstractTaskFactorySettings;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedAction;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.sequenceanalysis.SequenceAnalysisService;
import org.labkey.api.sequenceanalysis.SequenceOutputFile;
import org.labkey.api.sequenceanalysis.pipeline.ParameterizedOutputHandler;
import org.labkey.api.sequenceanalysis.pipeline.SequenceOutputHandler;
import org.labkey.api.sequenceanalysis.pipeline.ToolParameterDescriptor;
import org.labkey.api.util.FileType;
import org.labkey.sequenceanalysis.SequenceAnalysisServiceImpl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by bimber on 1/16/2015.
 */
public class SequenceOutputHandlerInitTask extends PipelineJob.Task<SequenceOutputHandlerInitTask.Factory>
{
    protected SequenceOutputHandlerInitTask(Factory factory, PipelineJob job)
    {
        super(factory, job);
    }

    public static class Factory extends AbstractTaskFactory<AbstractTaskFactorySettings, Factory>
    {
        public Factory()
        {
            super(SequenceOutputHandlerInitTask.class);
            setLocation("webserver");
        }

        public List<FileType> getInputTypes()
        {
            return Collections.emptyList();
        }

        public String getStatusName()
        {
            return PipelineJob.TaskStatus.running.toString();
        }

        public List<String> getProtocolActionNames()
        {
            List<String> allowableNames = new ArrayList<>();
            for (SequenceOutputHandler handler : SequenceAnalysisServiceImpl.get().getFileHandlers())
            {
                allowableNames.add(handler.getName());
            }

            return allowableNames;
        }

        public PipelineJob.Task createTask(PipelineJob job)
        {
            return new SequenceOutputHandlerInitTask(this, job);
        }

        public boolean isJobComplete(PipelineJob job)
        {
            return false;
        }
    }

    private SequenceOutputHandlerJob getPipelineJob()
    {
        return (SequenceOutputHandlerJob)getJob();
    }

    @NotNull
    public RecordedActionSet run() throws PipelineJobException
    {
        List<RecordedAction> actions = new ArrayList<>();

        SequenceOutputHandler handler = getPipelineJob().getHandler();
        List<SequenceOutputFile> outputsToCreate = new ArrayList<>();

        for (SequenceOutputFile f : getPipelineJob().getFiles())
        {
            f.cacheForRemoteServer();
            if (f.getLibrary_id() != null)
            {
                getPipelineJob().getSequenceSupport().cacheGenome(SequenceAnalysisService.get().getReferenceGenome(f.getLibrary_id(), getJob().getUser()));
            }
            getPipelineJob().getSequenceSupport().cacheExpData(f.getExpData());

            if (f.getReadset() != null)
            {
                getPipelineJob().getSequenceSupport().cacheReadset(f.getReadset(), getJob().getUser());
            }
        }

        getJob().getLogger().info("total inputs: " + getPipelineJob().getFiles().size());

        if (getPipelineJob().getParameterJson() != null)
        {
            getJob().getLogger().debug("job parameters:");
            getJob().getLogger().debug(getPipelineJob().getParameterJson().toString(1));
        }

        if (handler instanceof ParameterizedOutputHandler)
        {
            for (ToolParameterDescriptor pd : ((ParameterizedOutputHandler)handler).getParameters())
            {
                if (pd instanceof ToolParameterDescriptor.CachableParam)
                {
                    Object val = getPipelineJob().getParameterJson().opt(pd.getName());
                    ((ToolParameterDescriptor.CachableParam)pd).doCache(getJob(), val, getPipelineJob().getSequenceSupport());
                }
            }
        }

        handler.getProcessor().init(getJob(), getPipelineJob().getSequenceSupport(), getPipelineJob().getFiles(), getPipelineJob().getParameterJson(), getPipelineJob().getAnalysisDirectory(), actions, outputsToCreate);

        if (!outputsToCreate.isEmpty())
        {
            getJob().getLogger().info(outputsToCreate.size() + " to create");
            for (SequenceOutputFile o : outputsToCreate)
            {
                getPipelineJob().addOutputToCreate(o);
            }
        }

        return new RecordedActionSet(actions);
    }
}
