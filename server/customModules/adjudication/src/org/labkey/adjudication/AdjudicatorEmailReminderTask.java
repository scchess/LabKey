/*
 * Copyright (c) 2017 LabKey Corporation
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

import org.apache.log4j.Logger;
import org.labkey.api.util.SystemMaintenance.MaintenanceTask;

/**
 * Created by jimp on 9/10/2017.
 */
public class AdjudicatorEmailReminderTask implements MaintenanceTask
{
    @Override
    public String getDescription()
    {
        return "Send emails to adjudicators who have not made a determination or have cases that need resolution.";
    }

    @Override
    public String getName()
    {
        return "AdjudicatorEmailReminder";
    }

    @Override
    public void run(Logger log)
    {
        AdjudicationManager.get().emailAllAdjudicationContainersReminders();
    }
}
