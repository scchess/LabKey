/*
 * Copyright (c) 2016 LabKey Corporation
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

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.jmock.Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Test;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.labkey.adjudication.AdjudicationTeamUserTable.NOTIFY;
import static org.labkey.adjudication.AdjudicationTeamUserTable.TEAMNUMBER;

public class AdjudicationTeamUserQueryUpdateService extends DefaultQueryUpdateService
{

    public static final int maximumNumberOfAdjudicatorTeamMembers = 2;

    public AdjudicationTeamUserQueryUpdateService(TableInfo queryTable, TableInfo dbTable)
    {
        super(queryTable, dbTable);
    }

    @Override
    public List<Map<String, Object>> insertRows(User user, Container container, List<Map<String, Object>> rows,
                                                BatchValidationException errors, @Nullable Map<Enum, Object> configParameters,
                                                Map<String, Object> extraScriptContext)
                                                throws DuplicateKeyException, QueryUpdateServiceException, SQLException
    {
        try (DbScope.Transaction transaction = getDbTable().getSchema().getScope().ensureTransaction())
        {
            // Check for duplicates ahead of time;
            ensureUserIsNotAssignedToATeam(container, rows, errors);

            if (!errors.hasErrors())
            {
                List<Map<String, Object>> resultRows = super.insertRows(user, container, rows, errors, configParameters, extraScriptContext);
                if (!errors.hasErrors())
                {
                    validateChanges(container, errors);
                    if (!errors.hasErrors())
                    {
                        transaction.commit();
                        return resultRows;
                    }
                }
            }
        }
        return Collections.emptyList();
    }

    private void ensureUserIsNotAssignedToATeam(Container container, List<Map<String, Object>> rows, BatchValidationException errors)
    {
        Map<Integer, Map<String, Object>> userIdToOldRow = getTeamUserRowMap(container);
        rows.forEach((row) ->
        {
            if (userIdToOldRow.containsKey(row.get(AdjudicationTeamUserTable.ADJUDICATIONUSERID)))
                errors.addRowError(new ValidationException("User is already assigned to a team."));
        });
    }

    @Override
    public List<Map<String, Object>> updateRows(User user, Container container, List<Map<String, Object>> rows,
                                                List<Map<String, Object>> oldKeys, @Nullable Map<Enum, Object> configParameters,
                                                Map<String, Object> extraScriptContext)
                                                throws InvalidKeyException, BatchValidationException, QueryUpdateServiceException, SQLException
    {
        try (DbScope.Transaction transaction = getDbTable().getSchema().getScope().ensureTransaction())
        {
            List<Map<String, Object>> resultRows = super.updateRows(user, container, rows, oldKeys, configParameters, extraScriptContext);

            BatchValidationException errors = new BatchValidationException();
            validateChanges(container, errors);
            if (errors.hasErrors())
                throw errors;
            transaction.commit();
            return resultRows;
        }
    }

    private void validateChanges(Container container, BatchValidationException errors)
    {
        Map<Integer, Map<String, Object>> userIdToRow = getTeamUserRowMap(container);
        validateTeamMemberCount(errors, userIdToRow);
        validateTeamWillBeNotified(errors, userIdToRow);
    }

    private void validateTeamWillBeNotified(BatchValidationException errors, Map<Integer, Map<String, Object>> userIdToRow)
    {
        Map<Integer, Boolean> teamHasNotifyMember = new HashMap<>();
        for (Map<String, Object> row : userIdToRow.values())
        {
            Integer team = (Integer) row.get(AdjudicationTeamUserTable.TEAMNUMBER);
            Boolean notify = (Boolean) row.get(AdjudicationTeamUserTable.NOTIFY);
            if (!teamHasNotifyMember.containsKey(team))
            {
                teamHasNotifyMember.put(team, notify);
            }
            else
            {
                Boolean isTeamNotified = teamHasNotifyMember.get(team);
                teamHasNotifyMember.put(team, isTeamNotified || notify);
            }

        }
        for (Map.Entry<Integer, Boolean> teamEntry : teamHasNotifyMember.entrySet())
        {
            if(!teamEntry.getValue()){
                errors.addRowError(new ValidationException("Team " + teamEntry.getKey() + " must have at least one adjudicator set to receive notifications."));
            }
        }
    }

    private void validateTeamMemberCount(BatchValidationException errors, Map<Integer, Map<String, Object>> userIdToRow)
    {
        Map<Integer, Integer> teamUserCount = new HashMap<>();

        for (Map<String, Object> row : userIdToRow.values())
        {
            Integer team = (Integer) row.get(AdjudicationTeamUserTable.TEAMNUMBER);
            if (null != team)
            {
                // keep track of the number of adjudicators set for each team
                if (!teamUserCount.containsKey(team))
                    teamUserCount.put(team, 1);
                else
                    teamUserCount.put(team, teamUserCount.get(team) + 1);
            }
        }

        // Allow only 2 adjudicators to be set for each team (i.e. main adjudicator and a backup)
        for (Map.Entry<Integer, Integer> teamEntry : teamUserCount.entrySet())
        {
            if (teamEntry.getValue() > maximumNumberOfAdjudicatorTeamMembers)
            {
                errors.addRowError(new ValidationException("Team " + teamEntry.getKey() + " already has the maximum number of adjudicators."));
            }
        }
    }

    private Map<Integer, Map<String, Object>> getTeamUserRowMap(Container container)
    {
        Map<Integer, Map<String, Object>> userIdToRow = new HashMap<>();
        new TableSelector(getDbTable(), SimpleFilter.createContainerFilter(container), null)
                .forEachMap((map) -> userIdToRow.put((Integer) map.get(AdjudicationTeamUserTable.ADJUDICATIONUSERID), map));
        return userIdToRow;
    }

    public static class AdjudicationTeamUserQueryUpdateServiceTest
    {
        private AdjudicationTeamUserQueryUpdateService _mockService;
        private BatchValidationException errors = new BatchValidationException();
        private Map<Integer, Map<String, Object>> userIdToRow = new HashMap<>();
        private String errorMessage = "Team %d must have at least one adjudicator set to receive notifications.";

        public AdjudicationTeamUserQueryUpdateServiceTest()
        {
            createMockAdjudicationTeamUserQueryUpdateService();
        }

        @Test
        public void validateTeamWillBeNotifiedTest_One_Row_One_Team_Notify_True_Has_No_ErrorRow() throws Exception
        {
            int teamNumber = 1;
            boolean notify = true;
            addTeamUserToMap(teamNumber, notify);

            _mockService.validateTeamWillBeNotified(errors, userIdToRow );
            assertFalse(errors.hasErrors());
            assertEquals("Wrong number of errors",0,errors.getRowErrors().size());

        }

        @Test
        public void validateTeamWillBeNotifiedTest_One_Row_One_Team_Notify_False_Has_One_ErrorRow() throws Exception
        {
            int teamNumber = 1;
            boolean notify = false;
            addTeamUserToMap(teamNumber, notify);

            _mockService.validateTeamWillBeNotified(errors, userIdToRow );
            assertTrue(errors.hasErrors());
            assertEquals("Wrong number of errors",1,errors.getRowErrors().size());

            String expectedMessage = String.format(errorMessage, 1);
            assertEquals(expectedMessage, errors.getRowErrors().get(0).getMessage());
        }

        @Test
        public void validateTeamWillBeNotifiedTest_Two_Rows_One_Team_Notify_False_True_Has_No_Error() throws Exception
        {
            int teamNumber = 1;
            boolean notify = false;
            addTeamUserToMap(teamNumber, notify);
            addTeamUserToMap(teamNumber, true);

            _mockService.validateTeamWillBeNotified(errors, userIdToRow );
            assertFalse(errors.hasErrors());
            assertEquals("Wrong number of errors",0,errors.getRowErrors().size());
        }

        @Test
        public void validateTeamWillBeNotifiedTest_Two_Rows_Two_Teams_Notify_True_True_Has_No_Error() throws Exception
        {
            addTeamUserToMap(1, true);
            addTeamUserToMap(2, true);

            _mockService.validateTeamWillBeNotified(errors, userIdToRow );
            assertFalse(errors.hasErrors());
            assertEquals("Wrong number of errors",0,errors.getRowErrors().size());
        }

        @Test
        public void validateTeamWillBeNotifiedTest_Two_Rows_Two_Teams_Notify_True_False_Has_One_Error() throws Exception
        {
            addTeamUserToMap(1, true);
            addTeamUserToMap(2, false);

            _mockService.validateTeamWillBeNotified(errors, userIdToRow );
            assertTrue(errors.hasErrors());
            assertEquals("Wrong number of errors",1,errors.getRowErrors().size());

            String expectedMessage = String.format(errorMessage, 2);
            assertEquals(expectedMessage, errors.getRowErrors().get(0).getMessage());
        }

        @Test
        public void validateTeamWillBeNotifiedTest_Two_Rows_Two_Teams_Notify_False_False_Has_Two_Errors() throws Exception
        {
            addTeamUserToMap(1, false);
            addTeamUserToMap(2, false);

            _mockService.validateTeamWillBeNotified(errors, userIdToRow );
            assertTrue(errors.hasErrors());
            assertEquals("Wrong number of errors",2,errors.getRowErrors().size());

            String expectedMessage = String.format(errorMessage, 1);
            assertEquals(expectedMessage, errors.getRowErrors().get(0).getMessage());
            expectedMessage = String.format(errorMessage, 2);
            assertEquals(expectedMessage, errors.getRowErrors().get(1).getMessage());
        }

        private void addTeamUserToMap(int teamNumber, boolean notify)
        {
            Map<String, Object> value = new HashMap<>();
            value.put(TEAMNUMBER, teamNumber);
            value.put(NOTIFY, notify);
            userIdToRow.put(userIdToRow.size(), value);
        }

        @NotNull
        private void createMockAdjudicationTeamUserQueryUpdateService()
        {
            Mockery mock = new Mockery();
            mock.setImposteriser(ClassImposteriser.INSTANCE);
            TableInfo tableInfo = mock.mock(TableInfo.class);

            _mockService = new AdjudicationTeamUserQueryUpdateService(tableInfo, tableInfo);
        }


    }
}
