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
DROP TABLE cnprc_ehr.breedingRoster;

CREATE TABLE cnprc_ehr.breedingRoster (
  rowid INT IDENTITY(1,1) NOT NULL,
  animalId nvarchar(5),
  book nvarchar(2),
  maleEnemy1 nvarchar(5),
  maleEnemy2 nvarchar(5),
  maleEnemy3 nvarchar(5),
  maleEnemy4 nvarchar(5),
  maleEnemy5 nvarchar(5),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_BREEDING_ROSTER PRIMARY KEY (rowid),
  CONSTRAINT FK_BREEDING_ROSTER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX BREEDING_ROSTER_CONTAINER_INDEX ON cnprc_ehr.breedingRoster (Container);
CREATE INDEX CNPRC_EHR_BREEDING_ROSTER_OBJECTID_INDEX ON cnprc_ehr.breedingRoster (objectid);
GO