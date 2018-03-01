/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.datstat;

import org.apache.commons.beanutils.ConversionException;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLContextBuilder;
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
import org.apache.http.impl.client.HttpClientBuilder;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.collections.CaseInsensitiveHashSet;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.ConvertHelper;
import org.labkey.api.data.ForeignKey;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.TSVMapWriter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.validator.DateValidator;
import org.labkey.api.exp.property.Type;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.study.Study;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.XmlBeansUtil;
import org.labkey.api.writer.DefaultContainerUser;
import org.labkey.api.writer.FileSystemFile;
import org.labkey.api.writer.VirtualFile;
import org.labkey.data.xml.ColumnType;
import org.labkey.data.xml.TableType;
import org.labkey.data.xml.TablesDocument;
import org.labkey.data.xml.TablesType;
import org.labkey.datstat.export.DatStatResponse;
import org.labkey.datstat.export.ExportDataCommand;
import org.labkey.datstat.export.ExportMetadataCommand;
import org.labkey.datstat.export.ExportTestDataCommand;
import org.labkey.datstat.export.ExportTestMetadataCommand;
import org.labkey.study.xml.DatasetsDocument;
import org.labkey.study.xml.ExportDirType;
import org.labkey.study.xml.SecurityType;
import org.labkey.study.xml.StudyDocument;
import org.labkey.study.xml.TimepointType;
import org.labkey.study.xml.datStatExport.DatStatConfigDocument;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by klum on 2/18/2015.
 */
public class DatStatExport
{
    private static final String DEFAULT_DIRECTORY = "datasets";
    private static final String LISTS_DIRECTORY = "lists";
    private static final String MANIFEST_FILENAME = "datasets_manifest.xml";
    private static final String SCHEMA_FILENAME = "datasets_metadata.xml";

    private static final String LOOKUP_KEY_FIELD = "key";
    private static final String LOOKUP_NAME_FIELD = "name";

    private static final String METADATA_NAME_NODE = "Name";
    private static final String METADATA_VARIABLES_NODE = "Variables";
    private static final String METADATA_DATATYPE_NODE = "DataType";
    private static final String METADATA_SCALEVALUES_NODE = "ScaleValues";

    private static final String DATASET_NAME_NODE = "Name";
    private static final String DATASET_DATA_NODE = "Data";

    private static final String PTID_FIELD_NAME = "participantId";
    private static final String DATE_FIELD_NAME = "date";

    private static final String IGNORE_COLUMN_PREFIX = "DATSTAT";
    private static final String TIME_FIELD_FORMAT = "h:mm a";
    private static final String PCT_COMPLETE_COLUMN = "DATSTAT.PCTCOMPLETE";

    private PipelineJob _job;
    private Study _study;
    private DatStatManager.DatStatSettings _settings;
    private Map<String, Collection<ColumnInfo>> _datasetMetadata = new LinkedHashMap<>();
    private Map<String, List<Map<String, Object>>> _datasetData = new HashMap<>();
    private Map<String, Integer> _datasetNameToId = new HashMap<>();
    private TimepointType.Enum _timepointType = TimepointType.DATE;
    private Map<String, DatStatProject> _projects = new HashMap<>();
    private Map<String, List<Map<String, Object>>> _lookups = new HashMap<>();
    private Map<String, ColumnInfo> _columnInfoMap = new HashMap<>();
    private Map<String, DatStatProject.Form> _formMap = new HashMap<>();
    private boolean _test;
    private String _studyLabel = "DATStat Integration";

    public DatStatExport(PipelineJob job, Study study)
    {
        _job = job;
        _study = study;
        _settings = DatStatManager.get().getDatStatSettings(new DefaultContainerUser(job.getContainer(), job.getUser()));

        //_test = BooleanUtils.toBoolean(job.getActionURL().getParameter("test"));
        String metadata = _settings.getMetadata();
        if (metadata != null)
            parseConfiguration(metadata);
    }

    private void parseConfiguration(String metadata)
    {
        try
        {
            DatStatConfigDocument doc = DatStatConfigDocument.Factory.parse(metadata, XmlBeansUtil.getDefaultParseOptions());
            DatStatConfigDocument.DatStatConfig dc = doc.getDatStatConfig();

            String timepointType = dc.getTimepointType();

            if (timepointType.equalsIgnoreCase("visit"))
                _timepointType = TimepointType.VISIT;

            if (dc.getStudyLabel() != null)
                _studyLabel = dc.getStudyLabel();

            for (DatStatConfigDocument.DatStatConfig.Projects.Project project : dc.getProjects().getProjectArray())
            {
                if (!_projects.containsKey(project.getProjectName()))
                {
                    DatStatProject datStatProject = new DatStatProject(project);
                    _projects.put(project.getProjectName(), datStatProject);

                    for (DatStatProject.Form form : datStatProject.getFormMap().values())
                    {
                        _formMap.put(form.getName(), form);
                    }
                }
                else
                {
                    _job.error("Duplicate project names in the configuration file: " + project.getProjectName());
                }
            }
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
    }

    public void exportSource()
    {
        _job.info("Starting DATStat export");
        HttpClientBuilder builder = HttpClientBuilder.create();
        try
        {
            SSLContextBuilder sslContextBuilder = new SSLContextBuilder();
            sslContextBuilder.loadTrustMaterial(null, new TrustSelfSignedStrategy());
            SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(sslContextBuilder.build());
            builder.setSSLSocketFactory(sslConnectionSocketFactory);
        }
        catch (NoSuchAlgorithmException | KeyStoreException | KeyManagementException e)
        {
            _job.error("Error creating SSL Context", e);
            throw new RuntimeException(e);
        }
        HttpClient client = builder.build();

        for (DatStatProject project : _projects.values())
        {
            _job.info("Exporting DATStat Data Dictionary for project : " + project.getName());
            ExportMetadataCommand exportMetadataCommand;
            if (_test)
                exportMetadataCommand = new ExportTestMetadataCommand(_settings.getBaseServerUrl(), _settings.getUsername(), _settings.getPassword(), project.getName());
            else
                exportMetadataCommand = new ExportMetadataCommand(_settings.getBaseServerUrl(), _settings.getUsername(), _settings.getPassword(), project.getName());
            DatStatResponse response = exportMetadataCommand.execute(client);

            if (response != null && response.getStatusCode() == HttpStatus.SC_OK)
            {
                _job.info("Parsing returned metadata");
                parseMetadata(response.loadData(), project);
            }
            else
                _job.error("API request for dataset metadata failed : " + response.getText());

            if (_job.getErrors() == 0)
            {
                _job.info("Exporting DATStat Data for project : " + project.getName());
                ExportDataCommand exportDataCommand;
                if (_test)
                    exportDataCommand = new ExportTestDataCommand(_settings.getBaseServerUrl(), _settings.getUsername(), _settings.getPassword(), project.getName());
                else
                    exportDataCommand = new ExportDataCommand(_settings.getBaseServerUrl(), _settings.getUsername(), _settings.getPassword(), project.getName());
                DatStatResponse dataResponse = exportDataCommand.execute(client);

                if (dataResponse != null && dataResponse.getStatusCode() == HttpStatus.SC_OK)
                {
                    _job.info("Parsing returned data");
                    parseDatasetData(dataResponse.loadData(), project);
                }
                else
                    _job.error("API request for dataset data failed : " + response.getText());
            }
        }
        if (_job.getErrors() == 0)
            createStudyArchive();
    }

    private void createStudyArchive()
    {
        try
        {
            // write the study archive
            if (!_datasetMetadata.isEmpty())
            {
                File rootDir = _job.getPipeRoot().getRootPath();
                VirtualFile vf = new FileSystemFile(rootDir);

                // clean up target pipeline dirs
                FileUtil.deleteDir(new File(rootDir, DEFAULT_DIRECTORY));
                FileUtil.deleteDir(new File(rootDir, LISTS_DIRECTORY));

                // create the study.xml
                _job.info("Creating study archive");
                writeStudy(vf);

                // write the dataset metadata
                _job.info("Writing dataset metadata");
                writeDatasetMetadata(vf.getDir(DEFAULT_DIRECTORY));

                // add any lists or lookup data
                //if (!_lookups.isEmpty())
                {
                    _job.info("Creating column lookups");
                    writeLists(vf.getDir(LISTS_DIRECTORY));
                }

                // serialize to the individual tsv files
                writeDatasetData(vf.getDir(DEFAULT_DIRECTORY));

                vf.close();
                _job.info("Finished creating study archive");
            }

        }
        catch (IOException e)
        {
            _job.error("Error creating study archive", e);
        }
    }

    /**
     * Parses the metadata export response to create the datasets representation of the DATStat project
     * @return
     */
    private void parseMetadata(List<Map<String, Object>> metadata, DatStatProject project)
    {
        try
        {
            for (Map<String, Object> node : metadata)
            {
                String datasetName = (String)node.get(METADATA_NAME_NODE);
                if (datasetName != null)
                {
                    DatStatProject.Form form = project.getFormMap().get(datasetName);
                    boolean transform = form != null && form.isTransform();

                    if (form != null)
                    {
                        if (!_datasetMetadata.containsKey(datasetName))
                        {
                            Map<String, ColumnInfo> columns = new HashMap<>();

                            if (form.isExportAsList())
                            {
                                ColumnInfo col = new ColumnInfo(LOOKUP_KEY_FIELD);

                                col.setJdbcType(JdbcType.INTEGER);
                                col.setKeyField(true);
                                col.setHidden(true);

                                columns.put(LOOKUP_KEY_FIELD, col);

                                // also include ptid and date
                                ColumnInfo ptid = new ColumnInfo(PTID_FIELD_NAME);
                                ptid.setJdbcType(JdbcType.VARCHAR);
                                columns.put(PTID_FIELD_NAME, ptid);

                                ColumnInfo date = new ColumnInfo(DATE_FIELD_NAME);
                                date.setJdbcType(JdbcType.TIMESTAMP);
                                columns.put(DATE_FIELD_NAME, date);
                            }
                            else if (DatStatProject.MANAGED_KEY.equals(form.getKeyField()))
                            {
                                // LabKey managed key field
                                ColumnInfo col = new ColumnInfo(DatStatProject.MANAGED_KEY);

                                col.setJdbcType(JdbcType.INTEGER);
                                col.setKeyField(true);
                                col.setHidden(true);

                                columns.put(DatStatProject.MANAGED_KEY, col);

                                // LabKey duplicate indicator
                                ColumnInfo dupCol = new ColumnInfo(DatStatProject.DUPLICATE_FIELD_NAME);

                                dupCol.setJdbcType(JdbcType.BOOLEAN);
                                dupCol.setHidden(true);

                                columns.put(DatStatProject.DUPLICATE_FIELD_NAME, dupCol);
                            }

                            Object vars = node.get(METADATA_VARIABLES_NODE);
                            if (vars instanceof Map)
                            {
                                for (Map.Entry<String, Object> entry : ((Map<String, Object>)vars).entrySet())
                                {
                                    if (!entry.getKey().startsWith(IGNORE_COLUMN_PREFIX))
                                    {
                                        String columnName = getColumnName(entry.getKey(), transform);
                                        // reserved field names
                                        if (!PTID_FIELD_NAME.equalsIgnoreCase(columnName) && !DATE_FIELD_NAME.equalsIgnoreCase(columnName))
                                        {
                                            if (!columns.containsKey(columnName))
                                            {
                                                Object o = entry.getValue();
                                                if (o instanceof Map)
                                                {
                                                    Map varInfo = (Map)o;

                                                    String dataType = (String)varInfo.get(METADATA_DATATYPE_NODE);
                                                    Map<String, Object> scaleValues = (Map<String, Object>)varInfo.get(METADATA_SCALEVALUES_NODE);

                                                    columns.put(columnName, createColumnInfo(form, columnName, dataType, scaleValues));
                                                }
                                            }
                                            else
                                            {
                                                if (!transform)
                                                    _job.warn("Duplicate column : " + columnName + " found for non-transform dataset " + datasetName);
                                            }
                                        }
                                    }
                                }
                            }
                            _datasetMetadata.put(datasetName, columns.values());
                        }
                        else
                            _job.error("Dataset name: " + datasetName + " has already been processed.");
                    }
                    else
                    {
                        _job.warn("No form configuration for : " + datasetName + " ignoring.");
                    }
                }
            }
            _job.info("Finished parsing " + _datasetMetadata.size() + " datasets");
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Infer a column name which is typically to the same as the specified one unless it is a transformed dataset where column names
     * may have a numeric suffix to indicate the de-pivoted row.
     */
    private String getColumnName(String name, boolean isTransform)
    {
        if (isTransform)
        {
            int idx = name.lastIndexOf('_');
            if (idx != -1 && getColumnRowNumber(name, isTransform) != -1)
            {
                return name.substring(0, idx);
            }
        }
        return name;
    }

    private int getColumnRowNumber(String name, boolean isTransform)
    {
        if (isTransform)
        {
            int idx = name.lastIndexOf('_');
            if (idx != -1)
            {
                String suffix = name.substring(idx+1, name.length());
                if (NumberUtils.isDigits(suffix))
                    return NumberUtils.toInt(suffix, -1);
            }
        }
        return -1;
    }

    private ColumnInfo  createColumnInfo(DatStatProject.Form form,String name, String fieldType, @Nullable Map<String, Object> scaleValues)
    {
        ColumnInfo col = new ColumnInfo(name);
        if (fieldType != null)
        {
            if ("LongText".equalsIgnoreCase(fieldType) || "Text".equalsIgnoreCase(fieldType))
            {
                col.setJdbcType(JdbcType.VARCHAR);
                col.setInputType("textarea");
            }
            else if ("Integer".equalsIgnoreCase(fieldType) || "LongInteger".equalsIgnoreCase(fieldType) || "PositiveInteger".equalsIgnoreCase(fieldType))
                col.setJdbcType(JdbcType.INTEGER);
            else if ("Boolean".equalsIgnoreCase(fieldType))
                col.setJdbcType(JdbcType.BOOLEAN);
            else if ("Float".equalsIgnoreCase(fieldType))
                col.setJdbcType(JdbcType.DOUBLE);
            else if ("Time".equalsIgnoreCase(fieldType))
            {
                col.setJdbcType(JdbcType.TIMESTAMP);
                col.setFormat(TIME_FIELD_FORMAT);
            }
            else if ("DateTime".equalsIgnoreCase(fieldType))
                col.setJdbcType(JdbcType.TIMESTAMP);
            else if ("Date".equalsIgnoreCase(fieldType))
                col.setJdbcType(JdbcType.DATE);
            else if ("Guid".equalsIgnoreCase(fieldType))
                col.setJdbcType(JdbcType.VARCHAR);
            else
                col.setJdbcType(JdbcType.VARCHAR);

            // check for lookup values
            if (scaleValues != null)
            {
                Map<String, Object> scaleMap = scaleValues;

                // need to create the fk at export time
                if (!scaleMap.isEmpty())
                {
                    ForeignKey fk = new LookupForeignKey("key")
                    {
                        @Override
                        public TableInfo getLookupTableInfo()
                        {
                            return null;
                        }
                    };
                    col.setFk(fk);
                    createLookup(col, scaleMap);
                }
            }

            // check for an extra key field
            if (name.equalsIgnoreCase(form.getKeyField()))
                col.setKeyField(true);
        }
        else
        {
            _job.error("Column field type cannot be null");
            throw new IllegalArgumentException("Field type cannot be null");
        }
        _columnInfoMap.put(col.getName(), col);

        return col;
    }

    private void parseDatasetData(List<Map<String, Object>> metadata, DatStatProject project)
    {
        try
        {
            for (Map<String, Object> node : metadata)
            {
                String datasetName = (String)node.get(DATASET_NAME_NODE);
                if (datasetName != null)
                {
                    DatStatProject.Form form = project.getFormMap().get(datasetName);
                    boolean transform = form != null && form.isTransform();

                    if (form != null)
                    {
                        if (!_datasetData.containsKey(datasetName))
                        {
                            List<Map<String, Object>> rows = new ArrayList<>();
                            Object datasetData = node.get(DATASET_DATA_NODE);
                            if (datasetData instanceof List)
                            {
                                List<Map<String, String>> rowData = (List<Map<String, String>>)datasetData;
                                if (transform)
                                {
                                    rowData = transformRowData(rowData);
                                }

                                Set<PtidDate> uniqueRecs = new HashSet<>();
                                for (Map<String, String> row : rowData)
                                {
                                    String pctComplete = row.get(PCT_COMPLETE_COLUMN);
                                    if ("100".equals(pctComplete))
                                        parseDataRow(datasetName, form, rows, row, project, uniqueRecs);
                                    else
                                        _job.warn("DATSTAT.PCTCOMPLETE less than 100, skipping row: " + pctComplete);
                                }
                            }
                            _datasetData.put(datasetName, rows);
                        }
                        else
                            _job.error("Dataset name: " + datasetName + " has already been processed.");
                    }
                    else
                    {
                        _job.warn("No form configuration for : " + datasetName + " ignoring.");
                    }
                }
            }
            _job.info("Finished parsing " + _datasetData.size() + " datasets");
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * For each row of data in a transformed dataset, there will be potentially common field values that appear on every row and
     * field values that need to be associated with a specific row (through the field name numeric postfix).
     *
     * @param rowdata
     * @return
     */
    private List<Map<String, String>> transformRowData(List<Map<String, String>> rowdata)
    {
        List<Map<String, String>> newRows = new ArrayList<>();

        for (Map<String, String> row : rowdata)
        {
            Map<Integer, Map<String, String>> transformedRows = new HashMap<>();
            Map<String, String> commonProps = new HashMap<>();

            int startRow = Integer.MAX_VALUE;
            int endRow = 0;

            for (Map.Entry<String, String> entry : row.entrySet())
            {
                String colName = entry.getKey();
                int rowNum = getColumnRowNumber(colName, true);

                if (rowNum != -1)
                {
                    if (!transformedRows.containsKey(rowNum))
                    {
                        transformedRows.put(rowNum, new HashMap<String, String>());
                    }
                    transformedRows.get(rowNum).put(getColumnName(colName, true), entry.getValue());

                    startRow = Math.min(startRow, rowNum);
                    endRow = Math.max(endRow, rowNum);
                }
                else
                    commonProps.put(colName, entry.getValue());
            }

            // finally add the transformed rows into the newRows collection
            for (int i=startRow; i <= endRow; i++)
            {
                if (transformedRows.containsKey(i))
                {
                    Map<String, String> newRow = transformedRows.remove(i);

                    // push in the common fields
                    newRow.putAll(commonProps);
                    newRows.add(newRow);
                }
            }
        }
        return newRows;
    }

    private void parseDataRow(String datasetName, DatStatProject.Form form, List<Map<String, Object>> rows, Map<String, String> row,
                              DatStatProject project, Set<PtidDate> uniqueRecs)
    {
        Map<String, ColumnInfo> columnMap = new CaseInsensitiveHashMap<>();
        ConvertHelper.LenientTimestampConverter dateTimeConverter = new ConvertHelper.LenientTimestampConverter();
        boolean isManagedKey = DatStatProject.MANAGED_KEY.equals(form.getKeyField());

        if (_datasetMetadata.containsKey(datasetName))
        {
            String ptidFieldName = form != null ? form.getPtidField() : DatStatProject.DEFAULT_PTID_FIELD;
            String dateFieldName = form != null ? form.getDateField() : DatStatProject.DEFAULT_DATE_FIELD;
            boolean isDemographic = form != null && form.isDemographic();

            String ptid = null;
            Date date = null;

            for (ColumnInfo col : _datasetMetadata.get(datasetName))
            {
                columnMap.put(col.getName(), col);
            }

            // the new dataset data row
            Map<String, Object> datasetRow = new CaseInsensitiveHashMap<>();

            for (Map.Entry<String, String> entry : row.entrySet())
            {
                String colName = StringUtils.trim(entry.getKey());
                if (colName.equalsIgnoreCase(ptidFieldName))
                {
                    datasetRow.put(PTID_FIELD_NAME, entry.getValue());
                    ptid = entry.getValue();
                }
                else if (colName.equalsIgnoreCase(dateFieldName))
                {
                    date = convertDate(datasetName, entry.getValue(), row);
                    if (date != null)
                    {
                        datasetRow.put(DATE_FIELD_NAME, date);

                        // retain the original date field
                        if (!colName.equalsIgnoreCase(DATE_FIELD_NAME))
                            datasetRow.put(colName, date);
                    }
                }
                else
                {
                    ColumnInfo col = columnMap.get(colName);
                    if (col != null)
                    {
                        String value = entry.getValue();
                        if (col.getJdbcType().equals(JdbcType.TIMESTAMP) && value != null)
                        {
                            Date timestamp = (Date)dateTimeConverter.convert(Date.class, value);
                            datasetRow.put(col.getName(), timestamp);
                        }
                        else if (col.getJdbcType().equals(JdbcType.DATE) && value != null)
                        {
                            Date dateValue = convertDate(datasetName, value, row);
                            if (dateValue != null)
                                datasetRow.put(col.getName(), dateValue);
                        }
                        else
                            datasetRow.put(col.getName(), value);
                    }
                }
            }

            if (form.isExportAsList())
            {
                datasetRow.put(LOOKUP_KEY_FIELD, rows.size());
                rows.add(datasetRow);
            }
            else if (datasetRow.containsKey(PTID_FIELD_NAME))
            {
                if (!datasetRow.containsKey(DATE_FIELD_NAME))
                {
                    if (isDemographic)
                    {
                        datasetRow.put(DATE_FIELD_NAME, new Date());
                    }
                    else if (form.isUseDefaultDate() && project.getDefaultDate() != null)
                    {
                        _job.warn(String.format("parseDataRow : [%s : %s] record found without a date, using the configured default", datasetName, ptid));
                        date = project.getDefaultDate();
                        datasetRow.put(DATE_FIELD_NAME, date);
                    }
                    else if (form.isUseAlternateDate() && project.getAlternateDate() != null)
                    {
                        _job.warn(String.format("parseDataRow : [%s : %s] record found without a date, using the configured alternate", datasetName, ptid));
                        date = project.getAlternateDate();
                        datasetRow.put(DATE_FIELD_NAME, date);
                    }
                }

                if (datasetRow.containsKey(DATE_FIELD_NAME))
                {
                    PtidDate subject = new PtidDate(ptid, (Date)datasetRow.get(DATE_FIELD_NAME), isDemographic);
                    if (isManagedKey)
                    {
                        datasetRow.put(DatStatProject.MANAGED_KEY, rows.size() + 1);

                        // even though the managed key maintains uniqueness, we still want an indicator to show which records
                        // were duplicates without the managed key
                        if (uniqueRecs.contains(subject))
                        {
                            _job.warn(String.format("parseDataRow : [%s : %s : %s] record found with duplicate particpantID/date", datasetName, ptid, datasetRow.get(DATE_FIELD_NAME)));
                            datasetRow.put(DatStatProject.DUPLICATE_FIELD_NAME, true);
                        }
                    }

                    if (!isManagedKey && uniqueRecs.contains(subject))
                    {
                        // for now just warn, this will fail during the study import
                        if (isDemographic)
                            _job.warn(String.format("parseDataRow : [%s : %s] record found with duplicate particpantID", datasetName, ptid));
                        else
                            _job.warn(String.format("parseDataRow : [%s : %s : %s] record found with duplicate particpantID/date", datasetName, ptid, datasetRow.get(DATE_FIELD_NAME)));
                    }
                    else
                    {
                        uniqueRecs.add(subject);
                    }
                    rows.add(datasetRow);
                }
                else
                {
                    _job.warn(String.format("parseDataRow : [%s : %s] record found without a date", datasetName, ptid));
                }
            }
            else
            {
                _job.warn(String.format("parseDataRow : [%s] record found without a participantID", datasetName));
            }
        }
        else
            _job.warn("parseDataRow : no dataset metadata for dataset : " + datasetName);
    }

    @Nullable
    private Date convertDate(String datasetName, String dateStr, Map<String, String> row)
    {
        ConvertHelper.LenientDateConverter dateConverter = new ConvertHelper.LenientDateConverter();
        Date date = null;
        try
        {
            date = (Date)dateConverter.convert(Date.class, dateStr);
        }
        catch (ConversionException ce)
        {
            try
            {
                _job.warn(String.format("convertDate : [%s] Unable to convert date, attempting with alternate format", datasetName));
                date = DateUtil.parseDateTime(dateStr, "M/yyyy");
            }
            catch (ParseException pe)
            {
                StringBuilder sb = new StringBuilder();
                sb.append(String.format("convertDate : [%s] Error trying to convert to a date : %s %s", datasetName, dateStr, pe));
                sb.append("\nRow data:\n");

                for (Map.Entry<String, String> entry : row.entrySet())
                {
                    sb.append("\t").append(entry.getKey()).append(" : ").append(entry.getValue()).append("\n");
                }
                _job.error(sb.toString());
                return null;
            }
        }

        if (date != null)
        {
            DateValidator validator = new DateValidator("date");
            String error = validator._validate(0, date);
            if (error != null)
            {
                StringBuilder sb = new StringBuilder();
                sb.append(String.format("convertDate : [%s] date failed validation : [%s] error: [%s]", datasetName, date, error));
                sb.append("\nRow data:\n");

                for (Map.Entry<String, String> entry : row.entrySet())
                {
                    sb.append("\t").append(entry.getKey()).append(" : ").append(entry.getValue()).append("\n");
                }
                _job.error(sb.toString());
                return null;
            }
        }
        return date;
    }

    private void writeStudy(VirtualFile vf)
    {
        try {
            StudyDocument doc = StudyDocument.Factory.newInstance();
            StudyDocument.Study studyXml = doc.addNewStudy();

            // Archive version
            studyXml.setArchiveVersion(14.30);

            // Study attributes
            studyXml.setLabel(_studyLabel);

/*
            if (_config.getTimepointType().equals(TimepointType.VISIT))
            {
                studyXml.setTimepointType(_config.getTimepointType());
                StudyDocument.Study.Visits visitsXml = studyXml.addNewVisits();
                visitsXml.setFile(VISIT_FILENAME);
            }
*/
            studyXml.setTimepointType(_timepointType);
            studyXml.setSecurityType(SecurityType.BASIC_READ);

            StudyDocument.Study.Datasets datasetsXml = studyXml.addNewDatasets();
            datasetsXml.setDir(DEFAULT_DIRECTORY);
            datasetsXml.setFile(MANIFEST_FILENAME);

            if (!_lookups.isEmpty())
            {
                ExportDirType listsDir = studyXml.addNewLists();
                listsDir.setDir(LISTS_DIRECTORY);
            }

            StudyDocument.Study.Datasets.Definition definitionXml = datasetsXml.addNewDefinition();
            String datasetFilename = vf.makeLegalName("DATStat Integration.dataset");
            definitionXml.setFile(datasetFilename);

            // Save the study.xml file.  This gets called last, after all other writers have populated the other sections.
            vf.saveXmlBean("study.xml", doc);
        }
        catch (IOException e)
        {
            _job.error("Error creating study.xml", e);
            throw new RuntimeException(e);
        }
    }

    private void writeDatasetMetadata(VirtualFile vf)
    {
        try {

            DatasetsDocument manifestXml = DatasetsDocument.Factory.newInstance();
            DatasetsDocument.Datasets dsXml = manifestXml.addNewDatasets();
            DatasetsDocument.Datasets.Datasets2 datasets2Xml = dsXml.addNewDatasets();
            int datasetId = 1;

            // Create dataset metadata file
            TablesDocument tablesDoc = TablesDocument.Factory.newInstance();
            TablesType tablesXml = tablesDoc.addNewTables();

            for (Map.Entry<String, Collection<ColumnInfo>> entry : _datasetMetadata.entrySet())
            {
                String datasetName = entry.getKey();

                if (_formMap.containsKey(datasetName))
                {
                    DatStatProject.Form form = _formMap.get(datasetName);

                    if (!form.isExportAsList())
                    {
                        DatasetsDocument.Datasets.Datasets2.Dataset datasetXml = datasets2Xml.addNewDataset();
                        datasetXml.setName(datasetName);
                        datasetXml.setId(datasetId);

                        datasetXml.setType("Standard");

                        if (form.isDemographic())
                            datasetXml.setDemographicData(true);

                        _datasetNameToId.put(datasetName, datasetId++);

                        // create the dataset schemas
                        TableType tableXml = tablesXml.addNewTable();
                        tableXml.setTableName(datasetName);
                        tableXml.setTableDbType("TABLE");

                        TableType.Columns columnsXml = tableXml.addNewColumns();

                        for (ColumnInfo column : entry.getValue())
                        {
                            ColumnType columnXml = columnsXml.addNewColumn();
                            writeColumn(column, columnXml);
                        }
                    }
                }
            }
            String datasetFilename = vf.makeLegalName("DATStat Integration.dataset");

            try (PrintWriter writer = vf.getPrintWriter(datasetFilename))
            {
                writer.println("# default group can be used to avoid repeating definitions for each dataset\n" +
                        "#\n" +
                        "# action=[REPLACE,APPEND,DELETE] (default:REPLACE)\n" +
                        "# deleteAfterImport=[TRUE|FALSE] (default:FALSE)\n" +
                        "\n" +
                        "default.action=REPLACE\n" +
                        "default.deleteAfterImport=FALSE\n" +
                        "\n" +
                        "# map a source tsv column (right side) to a property name or full propertyURI (left)\n" +
                        "# predefined properties: ParticipantId, SiteId, VisitId, Created\n" +
                        "default.property.ParticipantId=ptid\n" +
                        "default.property.Created=dfcreate\n" +
                        "\n" +
                        "# use to map from filename->datasetid\n" +
                        "# NOTE: if there are NO explicit import definitions, we will try to import all files matching pattern\n" +
                        "# NOTE: if there are ANY explicit mapping, we will only import listed datasets\n" +
                        "\n" +
                        "default.filePattern=dataset(\\\\d*).tsv\n" +
                        "default.importAllMatches=TRUE");
            }

            dsXml.setMetaDataFile(SCHEMA_FILENAME);
            vf.saveXmlBean(MANIFEST_FILENAME, manifestXml);
            vf.saveXmlBean(SCHEMA_FILENAME, tablesDoc);
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    private void writeColumn(ColumnInfo col, ColumnType columnXml)
    {
        columnXml.setColumnName(col.getName());

        Class clazz = col.getJavaClass();
        Type t = Type.getTypeByClass(clazz);

        if (null == t)
        {
            _job.error(col.getName() + " has unknown java class " + clazz.getName());
            throw new IllegalStateException(col.getName() + " has unknown java class " + clazz.getName());
        }

        columnXml.setDatatype(t.getSqlTypeName());
        if (null != col.getLabel())
            columnXml.setColumnTitle(col.getLabel());

        if (null != col.getDescription())
            columnXml.setDescription(col.getDescription());

        if (col.isKeyField())
            columnXml.setIsKeyField(true);

        if (col.isHidden())
            columnXml.setIsHidden(true);

        String formatString = col.getFormat();
        if (null != formatString)
            columnXml.setFormatString(formatString);

        ForeignKey fk = col.getFk();

        if (null != fk && null != fk.getLookupColumnName())
        {
            if (_lookups.containsKey(col.getName()))
            {
                // Make sure public Name and SchemaName aren't null before adding the FK
                String tinfoPublicName = col.getName();
                String tinfoPublicSchemaName = "lists";
                if (null != tinfoPublicName && null != tinfoPublicSchemaName)
                {
                    ColumnType.Fk fkXml = columnXml.addNewFk();

                    fkXml.setFkDbSchema(tinfoPublicSchemaName);
                    fkXml.setFkTable(tinfoPublicName);
                    fkXml.setFkColumnName(fk.getLookupColumnName());
                }
            }
        }
    }

    /**
     * Creates the individual dataset exports
     */
    private void writeDatasetData(VirtualFile vf)
    {
        try {
            int datasetId;

            for (Map.Entry<String, List<Map<String, Object>>> entry : _datasetData.entrySet())
            {
                if (_datasetNameToId.containsKey(entry.getKey()))
                {
                    TSVMapWriter tsvWriter;

                    datasetId = _datasetNameToId.get(entry.getKey());
                    DatStatProject.Form form = _formMap.get(entry.getKey());

                    if (_datasetMetadata.containsKey(entry.getKey()))
                    {
                        Set<String> colNames = new CaseInsensitiveHashSet();
                        for (ColumnInfo col : _datasetMetadata.get(entry.getKey()))
                        {
                            colNames.add(col.getName());
                        }
                        colNames.add(PTID_FIELD_NAME);
                        colNames.add(DATE_FIELD_NAME);

                        tsvWriter = new TSVMapWriter(colNames, entry.getValue());
                    }
                    else
                    {
                        _job.warn("Writing dataset data : no column set found for dataset : " + entry.getKey());
                        tsvWriter = new TSVMapWriter(entry.getValue());
                    }

                    String fileName = String.format("dataset%03d.tsv", datasetId);

                    PrintWriter out = vf.getPrintWriter(fileName);
                    tsvWriter.write(out);
                    tsvWriter.close();
                }
            }
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    private void createLookup(ColumnInfo col, Map<String, Object> choices)
    {
        if (!_lookups.containsKey(col.getName()))
        {
            List<Map<String, Object>> lookup = new ArrayList<>();

            for (Map.Entry<String, Object> choice : choices.entrySet())
            {
                Map<String, Object> row = new HashMap<>();
                if (col.getJdbcType().equals(JdbcType.INTEGER))
                    row.put(LOOKUP_KEY_FIELD, new Integer(choice.getKey()));
                else if (col.getJdbcType().equals(JdbcType.VARCHAR))
                    row.put(LOOKUP_KEY_FIELD, choice.getKey());
                else
                {
                    StringBuilder sb = new StringBuilder();

                    sb.append("Column : " + col.getName() + " attempting to create a lookup for an " + col.getJdbcType().name() + " key type. Only int and string key fields supported.\n");
                    sb.append("Lookup Values\n");
                    for (Map.Entry<String, Object> entry : choices.entrySet())
                    {
                        sb.append("\t").append(entry.getKey()).append(" : ").append(String.valueOf(entry.getValue())).append("\n");
                    }
                    _job.warn(sb.toString());
                    return;
                }
                row.put(LOOKUP_NAME_FIELD, choice.getValue());

                lookup.add(row);
            }
            _lookups.put(col.getName(), lookup);
        }
    }

    /**
     * Serialize any lists to the archive. Lists are primarily used to be the target of a lookup but can also be used for CRF that
     * need to be imported as a list because they don't meet the requirements of a dataset.
     */
    private void writeLists(VirtualFile vf)
    {
        try
        {
            TablesDocument tablesDoc = TablesDocument.Factory.newInstance();
            TablesType tablesXml = tablesDoc.addNewTables();

            for (Map.Entry<String, List<Map<String, Object>>> entry : _lookups.entrySet())
            {
                // Write meta data
                // create the dataset schemas
                TableType tableXml = tablesXml.addNewTable();
                tableXml.setTableName(entry.getKey());
                tableXml.setTableDbType("TABLE");

                TableType.Columns columnsXml = tableXml.addNewColumns();

                tableXml.setPkColumnName(LOOKUP_KEY_FIELD);
                for (ColumnInfo column : getLookupColumns(entry.getKey()))
                {
                    ColumnType columnXml = columnsXml.addNewColumn();
                    writeColumn(column, columnXml);
                }

                TSVMapWriter tsvWriter = new TSVMapWriter(entry.getValue());
                PrintWriter out = vf.getPrintWriter(entry.getKey() + ".tsv");
                tsvWriter.write(out);
                tsvWriter.close();
            }

            // see if there are any datasets that need to be imported as a list
            for (Map.Entry<String, Collection<ColumnInfo>> entry : _datasetMetadata.entrySet())
            {
                String datasetName = entry.getKey();
                if (_formMap.containsKey(datasetName) && _datasetData.containsKey(datasetName))
                {
                    DatStatProject.Form form = _formMap.get(datasetName);
                    if (form.isExportAsList())
                    {
                        TableType tableXml = tablesXml.addNewTable();
                        tableXml.setTableName(datasetName);
                        tableXml.setTableDbType("TABLE");

                        TableType.Columns columnsXml = tableXml.addNewColumns();

                        tableXml.setPkColumnName(LOOKUP_KEY_FIELD);
                        for (ColumnInfo col : entry.getValue())
                        {
                            ColumnType columnXml = columnsXml.addNewColumn();
                            writeColumn(col, columnXml);
                        }

                        TSVMapWriter tsvWriter = new TSVMapWriter(_datasetData.get(datasetName));
                        PrintWriter out = vf.getPrintWriter(datasetName + ".tsv");
                        tsvWriter.write(out);
                        tsvWriter.close();
                    }
                }
            }

            vf.saveXmlBean("lists.xml", tablesDoc);
        }
        catch (IOException e)
        {
            _job.error(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private List<ColumnInfo> getLookupColumns(String columnName)
    {
        List<ColumnInfo> columns = new ArrayList<>();

        ColumnInfo parentCol = _columnInfoMap.get(columnName);
        if (parentCol != null)
        {
            ColumnInfo col = new ColumnInfo(LOOKUP_KEY_FIELD);

            col.setJdbcType(parentCol.getJdbcType());
            col.setKeyField(true);
            columns.add(col);

            ColumnInfo colName = new ColumnInfo(LOOKUP_NAME_FIELD);

            colName.setJdbcType(JdbcType.VARCHAR);
            columns.add(colName);
        }
        else
            _job.warn("Unable to locate the referencing column : " + columnName + " for the lookup list");
        return columns;
    }

    private static class PtidDate
    {
        private String _ptid;
        private Date _date;
        private boolean _isDemographic;

        public PtidDate(String ptid, Date date, boolean isDemographic)
        {
            _ptid = ptid;
            _date = date;
            _isDemographic = isDemographic;
        }

        @Override
        public int hashCode()
        {
            return _isDemographic ? _ptid.hashCode() : _ptid.hashCode() + _date.hashCode();
        }

        @Override
        public boolean equals(Object obj)
        {
            if (obj instanceof PtidDate)
            {
                if (_isDemographic)
                    return ((PtidDate)obj)._ptid.equals(_ptid);
                else
                    return ((PtidDate)obj)._ptid.equals(_ptid) && ((PtidDate)obj)._date.equals(_date);
            }
            return false;
        }
    }
}
