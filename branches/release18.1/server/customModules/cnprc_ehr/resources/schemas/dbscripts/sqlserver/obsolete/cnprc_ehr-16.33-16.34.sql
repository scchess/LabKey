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
CREATE TABLE cnprc_ehr.cage_location_history
(
  rowid INT IDENTITY(1,1) NOT NULL,
  location nvarchar(24),
  location_history_pk int,
  cage_size nvarchar(3),
  rate_class nvarchar(1),
  from_date datetime,
  to_date datetime,
  file_status nvarchar(2),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_CAGE_LOCATION_HISTORY PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_CAGE_LOCATION_HISTORY FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_CAGE_LOCATION_HISTORY_CONTAINER_INDEX ON cnprc_ehr.cage_location_history (Container);
GO

CREATE INDEX CNPRC_EHR_CAGE_LOCATION_HISTORY_OBJECTID_INDEX ON cnprc_ehr.cage_location_history (objectid);
GO

CREATE TABLE cnprc_ehr.room_enclosure
(
  rowid INT IDENTITY(1,1) NOT NULL,
  room nvarchar(100),
  file_status nvarchar(2),
  management_type nvarchar(1),
  supervisor nvarchar(12),
  weight_sheet_frequency nvarchar(1),
  food_id nvarchar(4),
  supplemental_diet nvarchar(1),
  remark nvarchar(14),
  isMhRoom bit,
  mh_group nvarchar(20),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_ROOM_ENCLOSURE PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_ROOM_ENCLOSURE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_ROOM_ENCLOSURE_CONTAINER_INDEX ON cnprc_ehr.room_enclosure (Container);
GO