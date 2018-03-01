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

import org.jmock.Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Test;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.BatchValidationException;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.labkey.adjudication.AdjudicationTeamUserTable.NOTIFY;
import static org.labkey.adjudication.AdjudicationTeamUserTable.TEAMNUMBER;

/**
 * Created by Ron on 5/18/2016.
 */
public class AdjudicationTeamUserQueryUpdateServiceTest
{
    @Test
    public void validateTeamWillBeNotifiedTest() throws Exception
    {
        Mockery mock = new Mockery();
        mock.setImposteriser(ClassImposteriser.INSTANCE);
        TableInfo tableInfo = mock.mock(TableInfo.class);

        MockAdjudicationTeamUserQueryUpdateService adjudicationTeamUserQueryUpdateService
                = new MockAdjudicationTeamUserQueryUpdateService(tableInfo, tableInfo);

        BatchValidationException errors = new BatchValidationException();
        Map<Integer, Map<String, Object>> userIdToRow = new HashMap<>();
        Map<String, Object> value = new HashMap<>();
        value.put(TEAMNUMBER,1);
        value.put(NOTIFY, false);
        userIdToRow.put(0, value);

//        adjudicationTeamUserQueryUpdateService.validateTeamWillBeNotified(errors, userIdToRow );
        assertTrue(errors.hasErrors());
        assertEquals("Wrong number of errors",1,errors.getRowErrors().size());

        String expectedMessage = "Team 1 has no adjudicator being notified.";
        assertEquals(expectedMessage, errors.getRowErrors().get(0).getMessage());
    }

    private class MockAdjudicationTeamUserQueryUpdateService extends AdjudicationTeamUserQueryUpdateService{

        public MockAdjudicationTeamUserQueryUpdateService(TableInfo queryTable, TableInfo dbTable)
        {
            super(queryTable, dbTable);
        }

        public void publicValidateTeamWillBeNotified(BatchValidationException errors, Map<Integer, Map<String, Object>> userIdToRow){
//            validateTeamWillBeNotified(errors, userIdToRow);
        }

    }

}