package org.labkey.sequenceanalysis.pipeline;

import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.PipelineJobService;
import org.labkey.api.pipeline.TaskId;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryAction;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.FileUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.sequenceanalysis.SequenceAnalysisManager;
import org.labkey.sequenceanalysis.SequenceAnalysisSchema;
import org.labkey.sequenceanalysis.model.ReferenceLibraryMember;

import java.beans.XMLDecoder;
import java.beans.XMLEncoder;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * User: bimber
 * Date: 7/21/2014
 * Time: 10:33 AM
 */
public class ReferenceLibraryPipelineJob extends SequenceJob
{
    public static final String FOLDER_NAME = "referenceLibrary";

    private String _assemblyId;
    private String _description;
    private Integer _libraryId = null;
    private ReferenceGenomeImpl _referenceGenome = null;
    private boolean _isNew;
    private boolean _skipCacheIndexes = false;
    private boolean _skipTriggers = false;
    private String _libraryName;
    private List<String> _unplacedContigPrefixes;

    public ReferenceLibraryPipelineJob(Container c, User user, PipeRoot pipeRoot, String libraryName, String assemblyId, String description, @Nullable List<ReferenceLibraryMember> libraryMembers, @Nullable Integer libraryId, boolean skipCacheIndexes, boolean skipTriggers, @Nullable List<String> unplacedContigPrefixes) throws IOException
    {
        super(ReferenceLibraryPipelineProvider.NAME, c, user, "referenceLibrary_" + FileUtil.getTimestamp(), pipeRoot, new JSONObject(), new TaskId(ReferenceLibraryPipelineJob.class), FOLDER_NAME);
        _assemblyId = assemblyId;
        _description = description;
        _libraryId = libraryId;
        _libraryName = libraryName;
        _isNew = libraryId == null;
        _skipCacheIndexes = skipCacheIndexes;
        _skipTriggers = skipTriggers;
        _unplacedContigPrefixes = unplacedContigPrefixes;

        saveLibraryMembersToFile(libraryMembers);
    }

    protected void saveLibraryMembersToFile(List<ReferenceLibraryMember> libraryMembers) throws IOException
    {
        if (libraryMembers != null)
        {
            try (XMLEncoder encoder = new XMLEncoder(new BufferedOutputStream(new FileOutputStream(getSerializedLibraryMembersFile()))))
            {
                getLogger().info("writing libraryMembers to XML: " + libraryMembers.size());
                encoder.writeObject(libraryMembers);
            }
        }
    }

    protected List<ReferenceLibraryMember> readLibraryMembersFromFile() throws IOException
    {
        File xml = getSerializedLibraryMembersFile();
        if (xml.exists())
        {
            try (XMLDecoder decoder = new XMLDecoder(new BufferedInputStream(new FileInputStream(xml))))
            {
                List<ReferenceLibraryMember> ret = (List<ReferenceLibraryMember>) decoder.readObject();
                getLogger().debug("read libraryMembers from file: " + ret.size());

                return ret;
            }
        }

        return null;
    }

    @Override
    protected void writeParameters(JSONObject params) throws IOException
    {
        //no need to write params
    }

    public File getSerializedLibraryMembersFile()
    {
        return new File(getDataDirectory(), FileUtil.getBaseName(getLogFile()) + ".xml");
    }

    //for recreating an existing library
    public static ReferenceLibraryPipelineJob recreate(Container c, User user, PipeRoot pipeRoot, Integer libraryId, boolean skipCacheIndexes, boolean skipTriggers) throws IOException
    {
        TableInfo ti = SequenceAnalysisSchema.getTable(SequenceAnalysisSchema.TABLE_REF_LIBRARIES);
        Map rowMap = new TableSelector(ti, new SimpleFilter(FieldKey.fromString("rowid"), libraryId), null).getMap();
        if (rowMap == null)
        {
            throw new IllegalArgumentException("Library not found: " + libraryId);
        }

        return new ReferenceLibraryPipelineJob(c, user, pipeRoot, (String)rowMap.get("name"), (String)rowMap.get("assemblyId"), (String)rowMap.get("description"), null, libraryId, skipCacheIndexes, skipTriggers, null);
    }

    @Override
    public String getDescription()
    {
        return (isCreateNew() ? "Create" : "Recreate") + " Reference Genome";
    }

    public String getLibraryName()
    {
        return _libraryName;
    }

    public String getLibraryDescription()
    {
        return _description;
    }

    public String getAssemblyId()
    {
        return _assemblyId;
    }

    public boolean isSkipTriggers()
    {
        return _skipTriggers;
    }

    public List<String> getUnplacedContigPrefixes()
    {
        return _unplacedContigPrefixes;
    }

    public List<ReferenceLibraryMember> getLibraryMembers() throws PipelineJobException
    {
        try
        {
            return readLibraryMembersFromFile();
        }
        catch (IOException e)
        {
            throw new PipelineJobException("Unable to read library file: " + getSerializedLibraryMembersFile().getPath(), e);
        }
    }

    @Override
    public JSONObject getParameterJson()
    {
        return new JSONObject();
    }

    public Integer getLibraryId()
    {
        return _libraryId;
    }

    public void setLibraryId(Integer libraryId)
    {
        _libraryId = libraryId;
    }

    public boolean isCreateNew()
    {
        return _isNew;
    }

    protected File createLocalDirectory(PipeRoot pipeRoot)
    {
        if (PipelineJobService.get().getLocationType() != PipelineJobService.LocationType.WebServer)
        {
            throw new RuntimeException("This method should only be called from the webserver");
        }

        File outputDir = SequenceAnalysisManager.get().getReferenceLibraryDir(getContainer());
        if (outputDir == null)
        {
            throw new RuntimeException("No pipeline directory set for folder: " + getContainer().getPath());
        }

        if (!outputDir.exists())
        {
            outputDir.mkdirs();
        }

        return outputDir;
    }

    @Override
    public ActionURL getStatusHref()
    {
        if (_libraryId != null)
        {
            ActionURL ret = QueryService.get().urlFor(getUser(), getContainer(), QueryAction.executeQuery, SequenceAnalysisSchema.SCHEMA_NAME, SequenceAnalysisSchema.TABLE_REF_LIBRARIES);
            ret.addParameter("query.rowid~eq", _libraryId);

            return ret;
        }
        return null;
    }

    public ReferenceGenomeImpl getReferenceGenome()
    {
        return _referenceGenome;
    }

    public void setReferenceGenome(ReferenceGenomeImpl referenceGenome)
    {
        _referenceGenome = referenceGenome;
    }

    public boolean skipCacheIndexes()
    {
        return _skipCacheIndexes;
    }
}
