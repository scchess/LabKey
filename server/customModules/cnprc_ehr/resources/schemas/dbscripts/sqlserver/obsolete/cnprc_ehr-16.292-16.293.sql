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

ALTER TABLE cnprc_ehr.key_assignments ADD objectid nvarchar(100);
ALTER TABLE cnprc_ehr.keys ADD objectid nvarchar(100);

CREATE TABLE cnprc_ehr.mh_file (

  fileNo int not null,
  fileName nvarchar(255),
  postTimestamp datetime,
  postUser nvarchar(30),
  readerBeginTimestamp datetime,
  readerNumber nvarchar(6),
  readerAttendant nvarchar(25),
  readerHeader_1 nvarchar(100),
  readerHeader_2 nvarchar(100),
  headerRecs int,
  dataRecs int,
  trailerRecs int,
  readerValidation nvarchar(1),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_MH_FILE PRIMARY KEY (fileNo),
  CONSTRAINT FK_CNPRC_MH_FILE_CONTAINER FOREIGN KEY (container) REFERENCES core.Containers (EntityId)

);
GO

CREATE INDEX CNPRC_MH_FILE_CONTAINER_INDEX ON cnprc_ehr.mh_file (Container);
GO

CREATE TABLE cnprc_ehr.mh_dump (

  mh_pk int,
  mhDate datetime,
  mhData text,
  computerName nvarchar(100),
  ipAddress nvarchar(20),
  login nvarchar(40),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_MH_DUMP PRIMARY KEY (mh_pk),
  CONSTRAINT FK_CNPRC_MH_DUMP_CONTAINER FOREIGN KEY (container) REFERENCES core.Containers (EntityId)

);
GO

CREATE INDEX CNPRC_MH_DUMP_CONTAINER_INDEX ON cnprc_ehr.mh_dump (Container);
GO