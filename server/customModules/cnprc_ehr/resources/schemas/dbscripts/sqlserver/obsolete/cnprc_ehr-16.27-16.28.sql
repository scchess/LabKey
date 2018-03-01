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

CREATE TABLE cnprc_ehr.department
(
  department_pk int,
  name nvarchar(50) NOT NULL,
  reports_to int,
  comment nvarchar(1000),
  instituion int,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_DEPARTMENT PRIMARY KEY (department_pk),
);


CREATE TABLE cnprc_ehr.key_name
(
  key_name_pk int,
  name nvarchar(15) NOT NULL,
  comment nvarchar(40),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_KEY_NAME PRIMARY KEY (key_name_pk),
);
GO

CREATE TABLE cnprc_ehr.keys
(
  key_pk int,
  number nvarchar(15),
  copy_number int,
  current_owner int,
  status nvarchar(15),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_KEY PRIMARY KEY (key_pk),
  CONSTRAINT FK_KEYS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO
CREATE TABLE cnprc_ehr.persons
(
  person_pk int,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PERSON PRIMARY KEY (person_pk),
  CONSTRAINT FK_PERSONS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE cnprc_ehr.key_assignments
(
  key_assignment_pk int,
  key_fk int,
  person_fk int,
  date_issued DATETIME,
  date_returned DATETIME,
  status nvarchar(15),
  comments nvarchar(1000),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_KEY_ASSIGNMENT PRIMARY KEY (key_assignment_pk),
  CONSTRAINT FK_KEY_ASSIGNMENTS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO