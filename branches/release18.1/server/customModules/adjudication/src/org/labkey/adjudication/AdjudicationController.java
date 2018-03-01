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
package org.labkey.adjudication;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.EnumUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.adjudication.security.AdjudicationCaseUploadPermission;
import org.labkey.adjudication.security.AdjudicationInfectionMonitorPermission;
import org.labkey.adjudication.security.AdjudicationPermission;
import org.labkey.adjudication.security.AdjudicationReviewPermission;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ExportAction;
import org.labkey.api.action.FormHandlerAction;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReturnUrlForm;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.admin.notification.NotificationService;
import org.labkey.api.attachments.Attachment;
import org.labkey.api.attachments.AttachmentFile;
import org.labkey.api.attachments.AttachmentForm;
import org.labkey.api.attachments.AttachmentParent;
import org.labkey.api.attachments.BaseDownloadAction;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Results;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryAction;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.Pair;
import org.labkey.api.util.ReturnURLString;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.NotFoundException;
import org.labkey.api.view.RedirectException;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletResponse;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static org.labkey.adjudication.AdjudicationUserSchema.ADJ_CASE_TABLE_NAME;

/**
 * Created by davebradlee on 9/28/15.
 *
 */
public class AdjudicationController extends SpringActionController
{
    private static final Logger _log = Logger.getLogger(AdjudicationController.class);
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(AdjudicationController.class);

    public AdjudicationController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public class DownloadAction extends BaseDownloadAction<AttachmentForm>
    {
        @Nullable
        @Override
        public Pair<AttachmentParent, String> getAttachment(AttachmentForm form)
        {
            AdjudicationAssayResultAttachmentParent parent = AdjudicationManager.get().getAssayResultAttachmentParent(getContainer(), getUser(), form.getEntityId());
            return new Pair<>(parent, form.getName());
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class DeleteAttachAdjudicationFileAction extends ApiAction<DeleteAttachFileForm>
    {
        private AdjudicationAssayResultAttachmentParent _parent = null;

        @Override
        public void validateForm(DeleteAttachFileForm form, Errors errors)
        {
            if (form.getEntityId() == null || form.getName() == null)
            {
                errors.reject(ERROR_MSG, "Missing required property");
            }
            else
            {
                _parent = AdjudicationManager.get().getAssayResultAttachmentParent(getContainer(), getUser(), form.getEntityId());

                if (AdjudicationManager.get().getAttachmentService().getAttachment(_parent, form.getName()) == null)
                {
                    errors.reject(ERROR_MSG, "Unable to find attachment: " + form.getName());
                }
            }
        }

        @Override
        public Object execute(DeleteAttachFileForm form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();
            AdjudicationManager.get().getAttachmentService().deleteAttachment(_parent, form.getName(), getUser());
            response.put("removed", form.getName());
            response.put("success", true);
            return response;
        }
    }

    public static class DeleteAttachFileForm
    {
        private String _entityId;
        private String _name;

        public String getEntityId()
        {
            return _entityId;
        }

        public void setEntityId(String entityId)
        {
            _entityId = entityId;
        }

        public String getName()
        {
            return _name;
        }

        public void setName(String name)
        {
            _name = name;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdjudicationCaseUploadPermission.class)
    public class AttachAdjudicationFilesAction extends ApiAction<AttachFilesForm>
    {
        public ApiResponse execute(AttachFilesForm form, BindException errors) throws Exception
        {
            if (null == form.getEntityId() || form.getEntityId().length() == 0)
                throw new IllegalArgumentException("The entityId parameter is required!");

            if (form.getRowId() < 0)
                throw new IllegalArgumentException("The rowId parameter is required!");

            if (!(getViewContext().getRequest() instanceof MultipartHttpServletRequest))
                throw new IllegalArgumentException("You must use the 'multipart/form-data' mime type when posting to attachFiles.api");

            AdjudicationAssayResultAttachmentParent parent = AdjudicationManager.get().getAssayResultAttachmentParent(getContainer(), getUser(), form.getRowId());
            if (null == parent)
                throw new IllegalArgumentException("Unable to identify parent directory.");

            Map<String, Object> warnings = new HashMap<>();

            String[] deleteNames = form.getToDelete();
            List<String> deleteList;
            if (null == deleteNames || 0 == deleteNames.length)
                deleteList = Collections.emptyList();
            else
                deleteList = Arrays.asList(deleteNames);

            String message = AdjudicationManager.get().updateAttachments(getUser(), parent, deleteList, getAttachmentFileList());

            if (null != message)
            {
                warnings.put("files", message);
            }

            //build the response
            ApiSimpleResponse resp = new ApiSimpleResponse();
            resp.put("success", true);
            if (warnings.size() > 0)
                resp.put("warnings", warnings);

            List<Object> attachments = new ArrayList<>();

            for (Attachment att : AdjudicationManager.get().getAttachmentService().getAttachments(parent))
            {
                Map<String, Object> attProps = new HashMap<>();
                attProps.put("name", att.getName());
                attachments.add(attProps);
            }

            resp.put("attachments", attachments);
            resp.put("caseId", form.getCaseId());
            return resp;
        }
    }

    public static class AttachFilesForm
    {
        private String _entityId;
        private int _rowId;
        private String _participantId;
        private int _caseId;
        private String[] _toDelete;

        public String getEntityId()
        {
            return _entityId;
        }

        public void setEntityId(String entityId)
        {
            _entityId = entityId;
        }

        public String[] getToDelete()
        {
            return _toDelete;
        }

        public void setToDelete(String[] toDelete)
        {
            _toDelete = toDelete;
        }

        public String getParticipantId()
        {
            return _participantId;
        }

        public void setParticipantId(String participantId)
        {
            _participantId = participantId;
        }

        public int getRowId()
        {
            return _rowId;
        }

        public void setRowId(int RowId)
        {
            _rowId = RowId;
        }

        public int getCaseId()
        {
            return _caseId;
        }

        public void setCaseId(int caseId)
        {
            _caseId = caseId;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdjudicationCaseUploadPermission.class)
    public class UpdateAdjudicationCaseAction extends ApiAction<CreateAdjudicationForm>
    {

        @Override
        public void validateForm(CreateAdjudicationForm form, Errors errors)
        {
            if (form.getCaseId() == null)
                errors.reject(ERROR_MSG, "No case ID for Adjudication Case");
            if (StringUtils.isBlank(form.getParticipantId()))
                errors.reject(ERROR_MSG, "No participantId for Adjudication Case");
            if (StringUtils.isBlank(form.getAssayFilename()))
                throw new IllegalStateException("No assay filename for Adjudication Case");

            SimpleFilter filter = SimpleFilter.createContainerFilter(getContainer());
            filter.addCondition(FieldKey.fromString("CaseId"), form.getCaseId());
            Set<String> columnNames = new HashSet<>();
            columnNames.add("ParticipantId");
            Map<String, Object>[] cases = new TableSelector(AdjudicationSchema.getInstance().getTableInfoAdjudicationCase(), columnNames,
                    filter, null).getMapArray();

            if (cases.length != 1)
                errors.reject(cases.length + "Adjudication cases found matching this name.");
            if (!cases[0].get("ParticipantId").equals(form.getParticipantId()))
                errors.reject(ERROR_MSG, "Participant ID does not match the case being updated.");
        }

        @Override
        public ApiResponse execute(CreateAdjudicationForm form, BindException errors) throws Exception
        {
            boolean success = false;
            ApiSimpleResponse response = new ApiSimpleResponse();

            if (form.getCaseId() != null)
            {
                AdjudicationSchema schema = AdjudicationSchema.getInstance();

                try (DbScope.Transaction transaction = schema.getSchema().getScope().ensureTransaction())
                {
                    // Get case
                    SimpleFilter filter = SimpleFilter.createContainerFilter(getContainer());
                    filter.addCondition(FieldKey.fromString("CaseId"), form.getCaseId());
                    Set<String> columnNames = new HashSet<>();
                    columnNames.add("Comment");
                    Map<String, Object>[] comment = new TableSelector(schema.getTableInfoAdjudicationCase(), columnNames,
                            filter, null).getMapArray();

                    // Update comment
                    String newComment = null != comment[0].get("Comment") ? (String) comment[0].get("Comment") : "";
                    newComment += " -- (Updated " + new SimpleDateFormat("ddMMMyyyy").format(new Date()) + ") " + form.getComment();
                    Map<String, Object> caseMap = new HashMap<>();
                    caseMap.put("Comment", newComment);
                    Table.update(getUser(), schema.getTableInfoAdjudicationCase(), caseMap, form.getCaseId());

                    List<Integer> rows = createVisits(form, form.getCaseId(), form.isCaseCompleted(), true, errors);
                    response.put("rows", rows);
                    response.put("caseId", form.getCaseId());
                    success = true;

                    AdjudicationManager.get().notifyOfCaseUpdate(getContainer(), getUser(), form.getCaseId(), false);

                    transaction.commit();
                }
                catch (Exception e)
                {
                    errors.reject(ERROR_MSG, e.getMessage());
                }
            }

            response.put("success", success);
            return response;
        }
    }

    public static class CaseFileForm
    {
        private Integer _caseId;
        private Integer _rowId;

        public Integer getCaseId()
        {
            return _caseId;
        }

        public void setCaseId(Integer caseId)
        {
            _caseId = caseId;
        }

        public Integer getRowId()
        {
            return _rowId;
        }

        public void setRowId(Integer rowId)
        {
            _rowId = rowId;
        }
    }

    @RequiresPermission(AdjudicationCaseUploadPermission.class)
    public class SaveAdjudicationCaseFileAction extends ApiAction<CaseFileForm>
    {
        @Override
        public ApiResponse execute(CaseFileForm form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();

            for (AttachmentFile file : getAttachmentFileList())
            {
                AdjudicationManager.get().insertCaseDocument(getUser(), getContainer(), form.getCaseId(), file);
                response.put("success", true);
            }
            return response;
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class DownloadCaseDocumentAction extends ExportAction<CaseFileForm>
    {
        @Override
        public void export(CaseFileForm form, HttpServletResponse response, BindException errors) throws Exception
        {
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("rowId"), form.getRowId());
            TableSelector selector = new TableSelector(AdjudicationSchema.getInstance().getTableInfoCaseDocuments(), filter, null);

            try (Results result = selector.getResults(false))
            {
                if (!result.next())
                    throw new NotFoundException("No case document available for rowId " + form.getRowId());

                String contentType = "application/text";
                byte[] documentBytes = IOUtils.toByteArray(result.getBinaryStream("document"));

                response.setContentType(contentType);
                response.setHeader("Content-Disposition", "attachment; filename=\"" + result.getString("documentName") + "\"");
                response.setContentLength(documentBytes.length);
                response.getOutputStream().write(documentBytes);
            }
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdjudicationCaseUploadPermission.class)
    public class CreateAdjudicationCaseAction extends ApiAction<CreateAdjudicationForm>
    {
        @Override
        public void validateForm(CreateAdjudicationForm form, Errors errors)
        {
            if (StringUtils.isBlank(form.getParticipantId()))
                errors.reject(ERROR_MSG, "No participantId for Adjudication Case");
            if (StringUtils.isBlank(form.getAssayFilename()))
                throw new IllegalStateException("No assay filename for Adjudication Case");
        }

        @Override
        public ApiResponse execute(CreateAdjudicationForm form, BindException errors) throws Exception
        {
            boolean success = false;
            ApiSimpleResponse response = new ApiSimpleResponse();

            initStatuses();     // TODO: figure out if user can change statuses and whether to make container-based

            // adjudication.Status should have ordered list of statuses. We want first one for new case
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("SequenceOrder"), 1);
            filter.addCondition(FieldKey.fromString("Container"), getContainer());
            Set<String> columnNames = new HashSet<>();
            columnNames.add("SequenceOrder");
            columnNames.add("RowId");
            Map<String, Object>[] statuses = new TableSelector(AdjudicationSchema.getInstance().getTableInfoStatus(), columnNames,
                    filter, null).getMapArray();
            if (statuses.length > 0)
            {
                try (DbScope.Transaction transaction = AdjudicationSchema.getInstance().getSchema().getScope().ensureTransaction())
                {
                    int caseId = createCase(form, (Integer) statuses[0].get("RowId"), errors);
                    response.put("caseId", caseId);

                    if (!errors.hasErrors() && form.getCaseId() != null)
                    {
                        deleteCase(form.getCaseId(), errors);
                    }

                    if (!errors.hasErrors())
                        success = true;

                    AdjudicationManager.get().notifyOfCaseUpdate(getContainer(), getUser(), caseId, true);

                    transaction.commit();
                }
                catch (Exception e)
                {
                    errors.reject(ERROR_MSG, "Error creating case: " + e.getMessage());
                }
            }
            else
            {
                errors.reject(ERROR_MSG, "Initial status not found.");
            }

            response.put("success", success);
            return response;
        }

        private void initStatuses()
        {
            AdjudicationSchema schema = AdjudicationSchema.getInstance();
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Container"), getContainer());
            TableSelector selector = new TableSelector(schema.getTableInfoStatus(), Collections.singleton("SequenceOrder"), filter, null);
            if (selector.getArrayList(Integer.class).isEmpty())
            {
                AdjudicationManager.get().insertStatus(getUser(), getContainer(), "Active Adjudication", 1);
                AdjudicationManager.get().insertStatus(getUser(), getContainer(), "Complete", 2);
            }
        }

        private int createCase(CreateAdjudicationForm form, Integer statusId, BindException errors) throws ParseException
        {
            AdjudicationSchema schema = AdjudicationSchema.getInstance();

            // Insert AdjudicationCase
            Map<String, Object> caseMap = AdjudicationManager.get().insertCase(getUser(), getContainer(), form, statusId);
            int caseId = (int) caseMap.get("CaseId");

            // Create new Determination for each adjudicator
            int numberOfAdjudicatorTeams = AdjudicationManager.get().getNumberOfAdjudicatorTeams(getContainer());
            for (int teamNumber = 1; teamNumber <= numberOfAdjudicatorTeams; teamNumber++)
            {
                AdjudicationManager.get().insertDetermination(getUser(), getContainer(), caseId, teamNumber);
            }

            createVisits(form, caseId, form.isCaseCompleted(), false, errors);
            return caseId;
        }

        private void deleteCase(Integer caseId, BindException errors)
        {
            SimpleFilter containerCaseFilter = SimpleFilter.createContainerFilter(getContainer());
            containerCaseFilter.addCondition(FieldKey.fromString(AssayResultsDomainKind.CASEID), caseId);

            deleteAssayResults(caseId, errors);
            Table.delete(AdjudicationSchema.getInstance().getTableInfoVisit(), containerCaseFilter);
            Table.delete(AdjudicationSchema.getInstance().getTableInfoDetermination(), containerCaseFilter);
            Table.delete(AdjudicationSchema.getInstance().getTableInfoAdjudicationCase(), containerCaseFilter);
        }

        private void deleteAssayResults(Integer caseId, BindException errors)
        {
            TableInfo assayResultsTable = AdjudicationSchema.getInstance().getTableInfoAssayResults(getContainer(), getUser());
            Set<ColumnInfo> cols = Collections.singleton(assayResultsTable.getColumn("EntityId"));
            SimpleFilter caseFilter = new SimpleFilter(FieldKey.fromParts(AssayResultsDomainKind.CASEID), caseId);

            List<String> entityIds = new TableSelector(assayResultsTable, cols, caseFilter, null).getArrayList(String.class);
            List<AttachmentParent> parentList = new ArrayList<>();
            for (String entityId : entityIds)
            {
                parentList.add(AdjudicationManager.get().getAssayResultAttachmentParent(getContainer(), getUser(), entityId));
            }
            AdjudicationManager.get().getAttachmentService().deleteAttachments(parentList);

            Table.delete(assayResultsTable, caseFilter);
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdjudicationCaseUploadPermission.class)
    public class VerifyLabReceiptAction extends ApiAction<AdjudicationIdForm>
    {
        @Override
        public void validateForm(AdjudicationIdForm form, Errors errors)
        {
            if (form.getAdjid() == null)
                errors.reject(ERROR_MSG, "No adjudication case ID provided.");
        }

        @Override
        public Object execute(AdjudicationIdForm form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();
            AdjudicationSchema schema = AdjudicationSchema.getInstance();

            try (DbScope.Transaction transaction = schema.getSchema().getScope().ensureTransaction())
            {
                // set lab verification date for this caseId
                Map<String, Object> caseMap = new HashMap<>();
                caseMap.put("LabVerified", new Date());
                Table.update(getUser(), schema.getTableInfoAdjudicationCase(), caseMap, form.getAdjid());

                // remove AdjudicationCaseReadyForVerification UI notifications for all users
                String notifType = AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseReadyForVerification.name();
                NotificationService.get().removeNotificationsByType(getContainer(), form.getAdjid().toString(), Collections.singletonList(notifType));

                response.put("success", true);
                transaction.commit();
            }
            catch (Exception e)
            {
                response.put("success", false);
                errors.reject(ERROR_MSG, e.getMessage());
            }

            return response;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(ReadPermission.class)
    public class RemoveCaseNotificationsAction extends ApiAction<AdjudicationIdForm>
    {
        @Override
        public void validateForm(AdjudicationIdForm form, Errors errors)
        {
            if (form.getAdjid() == null)
                errors.reject(ERROR_MSG, "No adjudication case ID provided.");
        }

        @Override
        public Object execute(AdjudicationIdForm form, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();
            AdjudicationSchema schema = AdjudicationSchema.getInstance();

            // remove UI notifications of specified types, or all types if non defined, for the given user
            List<String> notifTypes = new ArrayList<>();
            if (form.getNotificationType() != null)
            {
                notifTypes.add(form.getNotificationType());
            }
            else
            {
                notifTypes.add(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseCreated.name());
                notifTypes.add(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseAssayDataUpdated.name());
                notifTypes.add(AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseCompleted.name());
            }

            int count = NotificationService.get().removeNotifications(getContainer(), form.getAdjid().toString(), notifTypes, getUser().getUserId());
            response.put("notificationsRemoved", count);

            response.put("success", true);
            return response;
        }
    }

    private List<Integer> createVisits(CreateAdjudicationForm form, int caseId, boolean caseCompleted, boolean mergeResults, BindException errors) throws ParseException
    {
        // get any existing data
        HashMap<AdjudicationResult, AdjudicationResult> existingRows = new HashMap<>();

        TableInfo assayResults = AdjudicationSchema.getInstance().getTableInfoAssayResults(getContainer(), getUser());
        List<ColumnInfo> columns = assayResults.getColumns();

        if (mergeResults)
        {
            TableSelector selector = new TableSelector(AdjudicationSchema.getInstance().getTableInfoAssayResults(getContainer(), getUser()),
                    new SimpleFilter(FieldKey.fromParts(AssayResultsDomainKind.CASEID), form.getCaseId()), null);
            selector.forEachMap(row ->
            {
                AdjudicationResult result = new AdjudicationResult(getContainer(), columns, row);
                existingRows.put(result, result);
            });
        }

        // Insert CaseVisits
        for (Object visit : form.getVisits())
        {
            if (null != visit)
            {
                Double dVisit;
                try
                {
                    dVisit = Double.parseDouble(visit.toString());
                }
                catch (Exception e)
                {
                    errors.reject(ERROR_MSG, "Visit cannot be converted to Double.");
                    continue;
                }

                AdjudicationManager.get().insertVisit(getUser(), getContainer(), caseId, dVisit);
            }
        }

        // Insert AssayResults
        List<Integer> rowIds = new ArrayList<>();
        for (int i = 0; i < form.getAssayData().length(); i += 1)
        {
            Map<String, Object> row = AdjudicationManager.get().convertAssayResult(caseId, (JSONObject)form.getAssayData().get(i), getContainer());
            AdjudicationResult result = new AdjudicationResult(getContainer(), columns, row);
            if (!existingRows.containsKey(result))
            {
                if (form.isCaseCompleted())
                {
                    // if the row is updated after the case is complete, set the post complete flag on the result row
                    row.putIfAbsent(AssayResultsDomainKind.POSTCOMPLETE, true);
                }
                Map<String, Object> map = AdjudicationManager.get().insertAssayResult(getUser(), getContainer(), row);
                rowIds.add((Integer) map.get(AssayResultsDomainKind.ROWID));
            }
            else
            {
                AdjudicationResult existingRow = existingRows.get(result);
                // if this case has been completed, update existing rows to indicate they were added post completion
                Integer rowId = (Integer)existingRow.getRow().get(AssayResultsDomainKind.ROWID);
                rowIds.add(rowId);
            }
        }

        return rowIds;
    }

    /**
     * Helper class to detect duplicate result rows
     */
    public static class AdjudicationResult
    {
        private Container _c;
        private List<String> _columns = new ArrayList<>();
        private Map<String, Object> _row = new CaseInsensitiveHashMap<>();

        public AdjudicationResult(Container c, List<ColumnInfo> columns, Map<String, Object> row)
        {
            _c = c;
            _columns.addAll(columns.stream().map(ColumnInfo::getName).collect(Collectors.toList()));
            _row.putAll(row);
        }

        @Override
        public int hashCode()
        {
            int result = 0;

            for (String col : _columns)
            {
                if (_row.containsKey(col))
                {
                    Object o = normalize(col, _row.get(col));
                    if (o != null)
                    {
                        result = 31 * result + (o != null ? o.hashCode() : 0);
                        //_log.info("col : " + col + " value : " + o + " hashcode : " + o.hashCode());
                    }
                }
            }
            return result;
        }

        private Object normalize(String colName, Object o)
        {
            // ignore specific fields
            if (AssayResultsDomainKind.ENTITYID.equalsIgnoreCase(colName) ||
                    AssayResultsDomainKind.ROWID.equalsIgnoreCase(colName) ||
                    AssayResultsDomainKind.POSTCOMPLETE.equalsIgnoreCase(colName))
                return null;
            // need to try to normalize the types
            else if (o instanceof Date)
                o = DateUtil.formatDate(_c, (Date)o);
            else if ("visit".equalsIgnoreCase(colName) && o instanceof Integer)
                o = ((Integer)o).doubleValue();
            else if ("visit".equalsIgnoreCase(colName) && o instanceof Double)
                o = ((Double)o).doubleValue();
            else if (o instanceof Integer)
                o = ((Integer)o).toString();
            return o;
        }

        @Override
        public boolean equals(Object o)
        {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            AdjudicationResult that = (AdjudicationResult)o;

            if (!_columns.equals(that._columns)) return false;
            for (String col : _columns)
            {
                Object o1 = normalize(col, _row.get(col));
                Object o2 = normalize(col, that._row.get(col));

                if (o1 == null && o2 != null) return false;
                if (o1 != null && o2 == null) return false;
                if (o1 != null && !o1.equals(o2)) return false;
            }
            return true;
        }

        public Map<String, Object> getRow()
        {
            return _row;
        }
    }

    public static class CreateAdjudicationForm extends SimpleApiJsonForm
    {
        public String getParticipantId()
        {
            return getJsonObject().get("ParticipantId").toString();
        }

        public String getAssayFilename()
        {
            return getJsonObject().get("AssayFilename").toString();
        }

        public String getComment()
        {
            return getJsonObject().get("Comment").toString();
        }

        public Object[] getVisits()
        {
            return ((JSONArray) getJsonObject().get("Visits")).toArray();
        }

        public JSONArray getAssayData()
        {
            return (JSONArray) getJsonObject().get("AssayData");
        }

        public boolean isCaseCompleted()
        {
            return getJsonObject().getBoolean("CaseCompleted");
        }

        @Nullable
        public Integer getCaseId()
        {
            if (null != getJsonObject().get("CaseId"))
                return (Integer) getJsonObject().get("CaseId");
            else
                return null;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdjudicationPermission.class)
    public class MakeDeterminationAction extends ApiAction<DeterminationForm>
    {
        @Override
        public void validateForm(DeterminationForm form, Errors errors)
        {
            if (null == form.getRowId())
                errors.reject(ERROR_MSG, "Determination id must be present");
            if (null == form.getCaseId())
                errors.reject(ERROR_MSG, "Case id must be present");
            if (AdjudicationManager.get().requiresHiv1Determination(getContainer()) && StringUtils.isBlank(form.getHiv1Infected()))
                errors.reject(ERROR_MSG, "HIV-1 Infected field should be non-blank");
            if (AdjudicationManager.get().requiresHiv2Determination(getContainer()) && StringUtils.isBlank(form.getHiv2Infected()))
                errors.reject(ERROR_MSG, "HIV-2 Infected field should be non-blank");
            Integer adjudicatorUserId = form.getAdjudicator();
            if (null == adjudicatorUserId || getUser().getUserId() != adjudicatorUserId)
                errors.reject(ERROR_MSG, "Only assigned adjudicator can make determination");
        }

        @Override
        public ApiResponse execute(DeterminationForm form, BindException errors) throws Exception
        {
            boolean caseComplete = false;
            boolean caseUpdated = false;
            boolean confirmedInfection = false;
            AdjudicationSchema schema = AdjudicationSchema.getInstance();
            ApiSimpleResponse response = new ApiSimpleResponse();

            try (DbScope.Transaction transaction = schema.getSchema().getScope().ensureTransaction())
            {
                // adjudication.Status should have ordered list of statuses. We want last one for Complete TODO??
                SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Container"), getContainer());
                Set<String> columnNames = new HashSet<>();
                Sort sort = new Sort(FieldKey.fromString("SequenceOrder"));
                columnNames.add("SequenceOrder");
                columnNames.add("Status");
                columnNames.add("RowId");
                Map<String, Object>[] statuses = new TableSelector(schema.getTableInfoStatus(), columnNames,
                        filter, sort).getMapArray();

                Date now = new Date();

                // Update Determination
                Table.update(getUser(), schema.getTableInfoDetermination(), form.toValueMap(now, getUser()), form.getRowId());

                // Update Case
                Map<String, Object> caseMap = new HashMap<>();
                caseMap.put("Notified", false);
                if ("completed".equalsIgnoreCase(form.getStatus()))
                {
                    if (isAllDeterminationsDoneAndAgree(form.getCaseId()))
                    {
                        caseMap.put("StatusId", statuses[statuses.length - 1].get("RowId"));
                        caseMap.put("Completed", now);
                        caseComplete = true;
                        confirmedInfection = "yes".equalsIgnoreCase(form.getHiv1Infected()) || "yes".equalsIgnoreCase(form.getHiv2Infected());
                    }
                    Table.update(getUser(), schema.getTableInfoAdjudicationCase(), caseMap, form.getCaseId());
                    caseUpdated = true;
                }
                else if ("further testing required".equalsIgnoreCase(form.getHiv1Infected())
                        || "further testing required".equalsIgnoreCase(form.getHiv2Infected()))
                {
                    Table.update(getUser(), schema.getTableInfoAdjudicationCase(), caseMap, form.getCaseId());
                    caseUpdated = true;
                }
                transaction.commit();
            }
            catch (RuntimeSQLException e)
            {
                errors.reject(ERROR_MSG, e.getMessage());
            }

            if (errors.hasErrors())
            {
                response.put("success", false);
            }
            else
            {
                AdjudicationManager.get().notifyOfDeterminationUpdate(getContainer(), getUser(), form.getCaseId(), caseComplete, confirmedInfection);

                // if complete, remove any AdjudicationCaseResolutionRequired UI notifications for all Adjudicator users
                // else if still active, check if AdjudicationCaseResolutionRequired UI notifications need to be added
                if (caseComplete)
                {
                    String notifType = AdjudicationManager.NOTIFICATION_TYPE.AdjudicationCaseResolutionRequired.name();
                    NotificationService.get().removeNotificationsByType(getContainer(), form.getCaseId().toString(), Collections.singletonList(notifType));
                }
                else if (isDeterminationResolutionRequired(form.getCaseId()))
                {
                    AdjudicationManager.get().notifyOfResolutionRequired(getContainer(), getUser(), form.getCaseId());
                }

                response.put("caseUpdated", caseUpdated);
                response.put("caseId", form.getCaseId());
                response.put("success", true);
            }
            return response;
        }

        private List<CaseDetermination> getCaseDeterminationRows(int caseId)
        {
            AdjudicationSchema schema = AdjudicationSchema.getInstance();
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Container"), getContainer());
            filter.addCondition(FieldKey.fromString("CaseId"), caseId);
            Set<String> columns = new HashSet<>(Arrays.asList("Status", "RowId", "Hiv1Infected", "Hiv1InfectedVisit", "Hiv2Infected", "Hiv2InfectedVisit"));
            TableSelector selector = new TableSelector(schema.getTableInfoDetermination(), columns, filter, null);
            return selector.getArrayList(CaseDetermination.class);
        }

        private boolean isAllDeterminationsDoneAndAgree(int caseId)
        {
            String prevDeterminationStr = null;
            for (CaseDetermination row : getCaseDeterminationRows(caseId))
            {
                String hiv1Infected = row.getHiv1Infected();
                Double hiv1InfectedVisit = row.getHiv1InfectedVisit();
                String hiv2Infected = row.getHiv2Infected();
                Double hiv2InfectedVisit = row.getHiv2InfectedVisit();
                String currDeterminationStr = getDeterminationAsStr(hiv1Infected, hiv1InfectedVisit, hiv2Infected, hiv2InfectedVisit);

                // 1) case not done yet if any determination is not complete or is missing a required determination type
                if (!"completed".equalsIgnoreCase(row.getStatus())
                    || (AdjudicationManager.get().requiresHiv1Determination(getContainer()) && null == hiv1Infected)
                    || (AdjudicationManager.get().requiresHiv2Determination(getContainer()) && null == hiv2Infected))
                {
                    return false;
                }

                // 2) case not done yet if any determination is 'Further Testing Required'
                if ("Further Testing Required".equalsIgnoreCase(hiv1Infected) || "Further Testing Required".equalsIgnoreCase(hiv2Infected))
                {
                    return false;
                }

                // 3) case not done yet if all determinations do not match infected state and infected visit
                else if (prevDeterminationStr != null && !prevDeterminationStr.equals(currDeterminationStr))
                {
                    return false;
                }

                prevDeterminationStr = currDeterminationStr;
            }
            return true;
        }

        private boolean isDeterminationResolutionRequired(int caseId)
        {
            // return true if all case determinations are completed and any of the 4 relevant fields differ
            // return false if at least one determination is still pending or all determinations agree on 4 relevant fields
            Set<String> uniqueDeterminations = new HashSet<>();
            for (CaseDetermination row : getCaseDeterminationRows(caseId))
            {
                if ("pending".equalsIgnoreCase(row.getStatus()))
                    return false;

                String currDeterminationStr = getDeterminationAsStr(row.getHiv1Infected(), row.getHiv1InfectedVisit(),
                                                row.getHiv2Infected(), row.getHiv2InfectedVisit());
                uniqueDeterminations.add(currDeterminationStr);
            }

            return uniqueDeterminations.size() > 1;
        }

        private String getDeterminationAsStr(String hiv1Inf, Double hiv1InfVisit, String hiv2Inf, Double hiv2InfVisit)
        {
            return hiv1Inf + "|" + (hiv1InfVisit != null ? hiv1InfVisit.toString() : "")
                + "|" + hiv2Inf + "|" + (hiv2InfVisit != null ? hiv2InfVisit.toString() : "");
        }
    }

    public static class CaseDetermination
    {
        private int _rowId;
        private String _status;
        private String _hiv1Infected;
        private Double _hiv1InfectedVisit;
        private String _hiv2Infected;
        private Double _hiv2InfectedVisit;

        public int getRowId()
        {
            return _rowId;
        }
        public void setRowId(int rowId)
        {
            _rowId = rowId;
        }
        public String getStatus()
        {
            return _status;
        }
        public void setStatus(String status)
        {
            _status = status;
        }
        public String getHiv1Infected()
        {
            return _hiv1Infected;
        }
        public void setHiv1Infected(String hiv1Infected)
        {
            _hiv1Infected = hiv1Infected;
        }
        public Double getHiv1InfectedVisit()
        {
            return _hiv1InfectedVisit;
        }
        public void setHiv1InfectedVisit(Double hiv1InfectedVisit)
        {
            _hiv1InfectedVisit = hiv1InfectedVisit;
        }
        public String getHiv2Infected()
        {
            return _hiv2Infected;
        }
        public void setHiv2Infected(String hiv2Infected)
        {
            _hiv2Infected = hiv2Infected;
        }
        public Double getHiv2InfectedVisit()
        {
            return _hiv2InfectedVisit;
        }
        public void setHiv2InfectedVisit(Double hiv2InfectedVisit)
        {
            _hiv2InfectedVisit = hiv2InfectedVisit;
        }
    }

    public static class DeterminationForm
    {
        private Integer _rowId;
        private Integer _caseId;
        private Integer _adjudicator;
        private String _status;
        private String _hiv1Infected;
        private Integer _hiv1InfVisit;
        private String _hiv1Comment;
        private String _hiv2Infected;
        private Integer _hiv2InfVisit;
        private String _hiv2Comment;

        public Map<String, Object> toValueMap(Date now, User user)
        {
            Map<String, Object> values = new HashMap<>();

            values.put("Status", getStatus());
            values.put("Completed", "completed".equalsIgnoreCase(getStatus()) ? now : null);

            values.put("LastUpdated", now);
            values.put("LastUpdatedBy", user.getEmail());

            values.put("Hiv1Infected", getHiv1Infected());
            values.put("Hiv1InfectedVisit", getHiv1InfVisit());
            values.put("Hiv1Comment", getHiv1Comment());

            values.put("Hiv2Infected", getHiv2Infected());
            values.put("Hiv2InfectedVisit", getHiv2InfVisit());
            values.put("Hiv2Comment", getHiv2Comment());

            return values;
        }

        public Integer getRowId()
        {
            return _rowId;
        }

        public void setRowId(Integer rowId)
        {
            _rowId = rowId;
        }

        public Integer getCaseId()
        {
            return _caseId;
        }

        public void setCaseId(Integer caseId)
        {
            _caseId = caseId;
        }

        public Integer getAdjudicator()
        {
            return _adjudicator;
        }

        public void setAdjudicator(Integer adjudicator)
        {
            _adjudicator = adjudicator;
        }

        public String getStatus()
        {
            return _status;
        }

        public void setStatus(String status)
        {
            _status = status;
        }

        public String getHiv1Infected()
        {
            return _hiv1Infected;
        }

        public void setHiv1Infected(String hiv1Infected)
        {
            _hiv1Infected = hiv1Infected;
        }

        public Integer getHiv1InfVisit()
        {
            return _hiv1InfVisit;
        }

        public void setHiv1InfVisit(Integer hiv1InfVisit)
        {
            _hiv1InfVisit = hiv1InfVisit;
        }

        public String getHiv1Comment()
        {
            return _hiv1Comment;
        }

        public void setHiv1Comment(String hiv1Comment)
        {
            _hiv1Comment = hiv1Comment;
        }

        public String getHiv2Infected()
        {
            return _hiv2Infected;
        }

        public void setHiv2Infected(String hiv2Infected)
        {
            _hiv2Infected = hiv2Infected;
        }

        public Integer getHiv2InfVisit()
        {
            return _hiv2InfVisit;
        }

        public void setHiv2InfVisit(Integer hiv2InfVisit)
        {
            _hiv2InfVisit = hiv2InfVisit;
        }

        public String getHiv2Comment()
        {
            return _hiv2Comment;
        }

        public void setHiv2Comment(String hiv2Comment)
        {
            _hiv2Comment = hiv2Comment;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(ReadPermission.class)
    public class GetPermissionsAction extends ApiAction<Object>
    {
        @Override
        public ApiResponse execute(Object o, BindException errors) throws Exception
        {
            AdjudicationSchema schema = AdjudicationSchema.getInstance();
            Integer adjTeamNumber = AdjudicationManager.get().getAdjudicatorTeamNumber(getContainer(), getUser().getUserId());

            ApiSimpleResponse response = new ApiSimpleResponse();
            response.put("hasAdjudication", adjTeamNumber != null && getContainer().hasPermission(getUser(), AdjudicationPermission.class));
            response.put("hasCaseUpload", getContainer().hasPermission(getUser(), AdjudicationCaseUploadPermission.class));
            response.put("hasReview", getContainer().hasPermission(getUser(), AdjudicationReviewPermission.class));
            response.put("hasAdmin", getContainer().hasPermission(getUser(), AdminPermission.class));
            response.put("hasInfectionMonitor", getContainer().hasPermission(getUser(), AdjudicationInfectionMonitorPermission.class));
            response.put("success", true);
            return response;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdminPermission.class)
    public class AssayResultDesigner extends SimpleViewAction<ReturnUrlForm>
    {
        public ModelAndView getView(ReturnUrlForm form, BindException errors) throws Exception
        {
            throw new RedirectException(AdjudicationSchema.getInstance().getAssayResultsDomainKind()
                    .urlEditDefinition(AdjudicationSchema.getInstance().ensureAssayResultsDomain(getContainer(), getUser()), getViewContext()));
        }

        public NavTree appendNavTrail(NavTree root)
        {
            return root;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdminPermission.class)
    public class SetManageSettingsAction extends MutatingApiAction<ManageSettingsForm>
    {
        @Override
        public void validateForm(ManageSettingsForm form, Errors errors)
        {
            if (form.getPrefixType() == null || form.getRequiredDetermination() == null || form.getAdjudicatorTeamCount() == 0)
            {
                errors.reject(ERROR_MSG, "Missing required ManageSettingsForm value.");
            }
            else
            {
                if (!EnumUtils.isValidEnum(AdjudicationManager.FILE_NAME_PREFIX.class, form.getPrefixType()))
                {
                    errors.reject(ERROR_MSG, "Illegal prefix type: " + form.getPrefixType());
                }
                else
                {
                    if (AdjudicationManager.FILE_NAME_PREFIX.valueOf(form.getPrefixType()) == AdjudicationManager.FILE_NAME_PREFIX.studyName)
                    {
                        Container parent = getContainer().getParent();
                        StudyService studyService = StudyService.get();
                        if (null == parent || null == studyService || null == studyService.getStudy(parent))
                            errors.reject(ERROR_MSG, "Cannot find parent study for prefix type: studyName");
                    }

                    String filenamePrefix = AdjudicationManager.get().getFilenamePrefix(getContainer(), form.getPrefixType(), form.getPrefixText());
                    if (StringUtils.isNotBlank(filenamePrefix) && !FileUtil.isLegalName(filenamePrefix))
                    {
                        errors.reject(ERROR_MSG, "Prefix text contains illegal filename characters:" + form.getPrefixText());
                    }
                }

                if (form.getAdjudicatorTeamCount() < 1 || form.getAdjudicatorTeamCount() > 5)
                {
                    errors.reject(ERROR_MSG, "Invalid number of adjudicator teams: " + form.getAdjudicatorTeamCount());
                }

                if (!EnumUtils.isValidEnum(AdjudicationManager.REQUIRED_DETERMINATION.class, form.getRequiredDetermination()))
                {
                    errors.reject(ERROR_MSG, "Illegal required determinations type: " + form.getRequiredDetermination());
                }
            }
        }

        @Override
        public ApiResponse execute(ManageSettingsForm form, BindException errors) throws Exception
        {
            // if the number of teams is decreasing, remove any adjudicator team members previously assigned
            int previousNumberOfTeams = AdjudicationManager.get().getNumberOfAdjudicatorTeams(getContainer());
            if (form.getAdjudicatorTeamCount() < previousNumberOfTeams)
            {
                for (int i = previousNumberOfTeams; i > form.getAdjudicatorTeamCount(); i--)
                    AdjudicationManager.get().removeAdjudicatorTeamMembers(getContainer(), i);
            }

            // save the new admin settings
            AdjudicationManager.get().setManageSettingsProperties(getContainer(), form);
            ApiSimpleResponse response = new ApiSimpleResponse();
            response.put("success", true);
            return response;
        }
    }

    public static class ManageSettingsForm
    {
        private String _prefixType;
        private String _prefixText;
        private int _adjudicatorTeamCount;
        private String _requiredDetermination;

        public ManageSettingsForm()
        {
        }

        public String getPrefixType()
        {
            return _prefixType;
        }

        public void setPrefixType(String prefixType)
        {
            _prefixType = prefixType;
        }

        public String getPrefixText()
        {
            return _prefixText;
        }

        public void setPrefixText(String prefixText)
        {
            _prefixText = prefixText;
        }

        public int getAdjudicatorTeamCount()
        {
            return _adjudicatorTeamCount;
        }

        public void setAdjudicatorTeamCount(int adjudicatorTeamCount)
        {
            _adjudicatorTeamCount = adjudicatorTeamCount;
        }

        public String getRequiredDetermination()
        {
            return _requiredDetermination;
        }

        public void setRequiredDetermination(String requiredDetermination)
        {
            _requiredDetermination = requiredDetermination;
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class EmailReminderAction extends SimpleViewAction
    {
        @Override
        public ModelAndView getView(Object o, BindException errors) throws Exception
        {
            String caseId = getViewContext().getRequest().getParameter("caseId");

            // todo: show some kind of confirmation dialog asking if users really want to send reminders to adjudicators listed for this case

            // send an email to adjudicators of this case who have not completed their work
            AdjudicationManager.get().emailCaseReminders(getContainer(), Integer.parseInt(caseId));

            // when done redisplay the adjudication email reminders table
            ActionURL adjudicationCase = QueryService.get().urlFor(getViewContext().getUser(), getContainer(), QueryAction.executeQuery, "adjudication", ADJ_CASE_TABLE_NAME);
            return HttpView.redirect(adjudicationCase);
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Email Reminder Sent Confirmation");
        }
    }

    @RequiresPermission(AdjudicationPermission.class)
    public class AdjudicationDeterminationAction extends SimpleViewAction<AdjudicationIdForm>
    {
        @Override
        public ModelAndView getView(AdjudicationIdForm form, BindException errors) throws Exception
        {
            return new JspView<>("/org/labkey/adjudication/view/adjudicationDetermination.jsp", form);
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Adjudication Determinations");
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class AdjudicationReviewAction extends SimpleViewAction<AdjudicationIdForm>
    {
        @Override
        public ModelAndView getView(AdjudicationIdForm form, BindException errors) throws Exception
        {
            return new JspView<>("/org/labkey/adjudication/view/adjudicationReview.jsp", form);
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Adjudication Review");
        }
    }

    public static class AdjudicationIdForm
    {
        private Integer _adjid;
        private boolean _isAdminReview;
        private String _notificationType;

        public Integer getAdjid()
        {
            return _adjid;
        }

        public void setAdjid(Integer adjid)
        {
            _adjid = adjid;
        }

        public boolean isAdminReview()
        {
            return _isAdminReview;
        }

        public void setIsAdminReview(boolean adminReview)
        {
            _isAdminReview = adminReview;
        }

        public String getNotificationType()
        {
            return _notificationType;
        }

        public void setNotificationType(String notificationType)
        {
            _notificationType = notificationType;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdminPermission.class)
    public class SetDefaultAssayTypesAction extends FormHandlerAction<Object>
    {
        public void validateCommand(Object form, Errors errors)
        {
            // setDefaultAssayTypes will throw (duplicate key) and report error if we try to add dups
        }

        @Override
        public boolean handlePost(Object form, BindException errors)
        {
            try
            {
                AdjudicationManager.get().setDefaultAssayTypes(getContainer(), getUser());
            }
            catch (Exception e)
            {
                errors.reject(SpringActionController.ERROR_MSG, "Error setting assay type defaults: " + e.getMessage());
            }

            return !errors.hasErrors();
        }

        public ActionURL getSuccessURL(Object form)
        {
            URLHelper urlHelper = getViewContext().getActionURL().getReturnURL();
            return null != urlHelper ? new ReturnURLString(urlHelper.getURIString()).getActionURL() : null;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    @RequiresPermission(AdminPermission.class)
    public class SetDefaultSupportedKitsAction extends FormHandlerAction<Object>
    {
        public void validateCommand(Object form, Errors errors)
        {
            // setDefaultAssayTypes will throw (duplicate key) and report error if we try to add dups
        }

        @Override
        public boolean handlePost(Object form, BindException errors)
        {
            try
            {
                AdjudicationManager.get().setDefaultSupportedKits(getContainer(), getUser());
            }
            catch (Exception e)
            {
                errors.reject(SpringActionController.ERROR_MSG, "Error setting supported kit defaults: " + e.getMessage());
            }

            return !errors.hasErrors();
        }

        public ActionURL getSuccessURL(Object form)
        {
            URLHelper urlHelper = getViewContext().getActionURL().getReturnURL();
            return null != urlHelper ? new ReturnURLString(urlHelper.getURIString()).getActionURL() : null;
        }
    }}
