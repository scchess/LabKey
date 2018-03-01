/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
DROP TABLE adjudication.Adjudicator
GO

ALTER TABLE adjudication.Determination DROP COLUMN Infected;
ALTER TABLE adjudication.Determination DROP COLUMN InfectedDate;
ALTER TABLE adjudication.Determination DROP COLUMN Comment;

ALTER TABLE adjudication.Determination ADD Hiv1Infected NVARCHAR(200);
ALTER TABLE adjudication.Determination ADD Hiv2Infected NVARCHAR(200);
ALTER TABLE adjudication.Determination ADD Hiv1InfDate DATETIME;
ALTER TABLE adjudication.Determination ADD Hiv2InfDate DATETIME;
ALTER TABLE adjudication.Determination ADD Hiv1Comment NVARCHAR(500);
ALTER TABLE adjudication.Determination ADD Hiv2Comment NVARCHAR(500);
