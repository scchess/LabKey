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

/* targetedms-15.10-15.11.sql */

CREATE TABLE targetedms.GuideSet
(
  RowId INT IDENTITY(1, 1) NOT NULL,
  Container ENTITYID NOT NULL,
  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,
  TrainingStart DATETIME NOT NULL,
  TrainingEnd DATETIME NOT NULL,
  Comment TEXT,

  CONSTRAINT PK_GuideSet PRIMARY KEY (RowId)
);

/* targetedms-15.11-15.12.sql */

ALTER TABLE targetedms.GuideSet ALTER COLUMN Comment NVARCHAR(MAX);