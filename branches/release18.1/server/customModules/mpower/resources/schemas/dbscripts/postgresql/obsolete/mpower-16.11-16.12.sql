/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
ALTER TABLE mpower.Participant ADD COLUMN Arm1Consent BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE mpower.Participant ADD COLUMN Arm2Consent BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE mpower.Participant ADD COLUMN FutureResearchConsent BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE mpower.Participant ADD COLUMN Signature VARCHAR(64);

