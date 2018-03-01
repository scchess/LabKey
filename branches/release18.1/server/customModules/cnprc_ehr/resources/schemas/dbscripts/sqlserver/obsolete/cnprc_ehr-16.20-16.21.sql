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

CREATE SCHEMA cnprc_ehr;
GO

CREATE TABLE cnprc_ehr.spf_status (

  id int not null,
  name NVARCHAR(20),
  status NVARCHAR(2),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_SPF_STATUS PRIMARY KEY (id),
  CONSTRAINT FK_SPF_STATUS FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE cnprc_ehr.protocol_exceptions (

  id int not null,
  protocol NVARCHAR(20),
  animalId NVARCHAR(10),
  exceptionCode NVARCHAR(2),
  comments NVARCHAR(500),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_PROTOCOL_EXEMPTIONS PRIMARY KEY (id),
  CONSTRAINT FK_PROTOCOL_EXEMPTIONS FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO