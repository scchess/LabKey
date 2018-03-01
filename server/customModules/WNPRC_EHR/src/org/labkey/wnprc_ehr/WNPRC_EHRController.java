/*
 * Copyright (c) 2012-2016 LabKey Corporation
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
package org.labkey.wnprc_ehr;

import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Results;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.demographics.AnimalRecord;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryHelper;
import org.labkey.api.security.CSRF;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.util.ExceptionUtil;
import org.labkey.api.util.ResultSetUtil;
import org.springframework.validation.BindException;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:56 PM
 */
public class WNPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(WNPRC_EHRController.class);

    public WNPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    @CSRF
    public class GetAnimalDemographicsForRoomAction extends ApiAction<GetAnimalDemographicsForRoomForm>
    {
        public ApiResponse execute(GetAnimalDemographicsForRoomForm form, BindException errors) throws Exception {
            Map<String, Object> props = new HashMap<>();

            if (form.getRoom() == null) {
                errors.reject(ERROR_MSG, "No Room Specified");
                return null;
            }

            Results rs = null;
            List<String> animalIds = new ArrayList<String>();

            try {
                // Set up our query
                SimpleFilter filter = new SimpleFilter(FieldKey.fromString("room"), form.getRoom());
                QueryHelper animalListQuery = new QueryHelper(getContainer(), getUser(), "study", "demographicsCurLocation");

                // Define columns to get
                List<FieldKey> columns = new ArrayList<FieldKey>();
                columns.add(FieldKey.fromString("room"));
                columns.add(FieldKey.fromString("Id"));

                // Execute the query
                rs = animalListQuery.select(columns, filter);

                // Now, execute it to get our list of Ids
                if (rs.next()) {
                    do {
                        animalIds.add(rs.getString(FieldKey.fromString("Id")));
                    } while (rs.next());
                }

                try {
                    JSONObject json = new JSONObject();
                    for (AnimalRecord r : EHRDemographicsService.get().getAnimals(getContainer(), animalIds))
                    {
                        json.put(r.getId(), r.getProps());
                    }

                    props.put("results", json);
                }
                catch(Exception e) {
                    ExceptionUtil.logExceptionToMothership(getViewContext().getRequest(), e);
                }
            }
            catch(SQLException e) {
                throw new RuntimeSQLException(e);
            }
            finally {
                ResultSetUtil.close(rs);
            }

            return new ApiSimpleResponse(props);
        }
    }

    public static class GetAnimalDemographicsForRoomForm {
        private String _room;
        public String getRoom() {
            return _room;
        }
        public void setRoom(String room) {
            _room = room;
        }
    }
}
