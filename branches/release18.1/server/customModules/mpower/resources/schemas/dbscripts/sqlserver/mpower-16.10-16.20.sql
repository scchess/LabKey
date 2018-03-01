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

/* mpower-16.10-16.11.sql */

EXEC core.fn_dropifexists 'Participant', 'mpower', 'CONSTRAINT', 'UQ_RequestStatus';

/* mpower-16.11-16.12.sql */

ALTER TABLE mpower.Participant ADD Arm1Consent BIT NOT NULL DEFAULT 0;
ALTER TABLE mpower.Participant ADD Arm2Consent BIT NOT NULL DEFAULT 0;
ALTER TABLE mpower.Participant ADD FutureResearchConsent BIT NOT NULL DEFAULT 0;
ALTER TABLE mpower.Participant ADD Signature NVARCHAR(64);