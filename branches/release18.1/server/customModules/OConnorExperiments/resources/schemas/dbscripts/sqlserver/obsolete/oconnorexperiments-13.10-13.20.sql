/*
 * Copyright (c) 2013-2015 LabKey Corporation
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

/* oconnorexperiments-13.10-13.11.sql */

-- Modified column was mistakenly created as TIMESTAMP
ALTER TABLE oconnorexperiments.Experiments
    DROP COLUMN Modified;
GO
ALTER TABLE oconnorexperiments.Experiments
    ADD Modified DATETIME;
GO

UPDATE oconnorexperiments.Experiments SET Modified = CURRENT_TIMESTAMP;
GO

/* oconnorexperiments-13.11-13.12.sql */

-- drop ParentExperiments.Container FK to allow bulk folder delete
EXEC core.fn_dropifexists 'ParentExperiments', 'OConnorExperiments', 'constraint', 'FK_ParentExperiments_Container';
GO
