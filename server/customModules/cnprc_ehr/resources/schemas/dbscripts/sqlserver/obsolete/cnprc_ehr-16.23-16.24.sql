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


CREATE TABLE cnprc_ehr.rd_lung_lobe_vol
(
  id int not null,
  animalId nvarchar(10),
  project_code nvarchar(5),
  rt_mid_lobe_vol float,
  rt_mid_lobe_fix nvarchar(20),
  rt_cra_lobe_vol float,
  rt_cra_lobe_fix nvarchar(20),
  lt_cra_lobe_vol float,
  lt_cra_lobe_fix nvarchar(20),
  llv_comments nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_RD_LUNG_LOBE_VOL PRIMARY KEY (id),
  CONSTRAINT FK_CNPRC_EHR_RD_LUNG_LOBE_VOL FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_RD_LUNG_LOBE_VOL_CONTAINER_INDEX ON cnprc_ehr.rd_lung_lobe_vol (Container);
GO

CREATE TABLE cnprc_ehr.rd_master
(
  id int not null,
  an_id int,
  species nvarchar(3),
  animalId nvarchar(10),
  proj_code_1 nvarchar(5),
  proj_code_2 nvarchar(5),
  treatment nvarchar(40),
  stagger_group nvarchar(10),
  age_category nvarchar(20),
  birthdate datetime,
  death_date datetime,
  necropsy_wt_kg float,
  gender nvarchar(1),
  birthplace nvarchar(9),
  dam nvarchar(5),
  dam_genetics_verify nvarchar(1),
  sire nvarchar(5),
  sire_genetics_verify nvarchar(1),
  genetics_comment nvarchar(20),
  comments nvarchar(1024),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_RD_MASTER PRIMARY KEY (id),
  CONSTRAINT FK_CNPRC_EHR_RD_MASTER FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_RD_MASTER_CONTAINER_INDEX ON cnprc_ehr.rd_master (Container);
GO

CREATE TABLE cnprc_ehr.rd_project_category
(
  rowid INT IDENTITY(1,1) NOT NULL,
  projectCode	nvarchar(5),
  timeframe	nvarchar(10),
  comment1	nvarchar(60),
  comment2	nvarchar(60),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_RD_PROJECT_CATEGORY PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_RD_PROJECT_CATEGORY FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_RD_PROJECT_CATEGORY_CONTAINER_INDEX ON cnprc_ehr.rd_project_category (Container);
GO

CREATE TABLE cnprc_ehr.rd_protocol_procedure
(
  rowid INT IDENTITY(1,1) NOT NULL,
  project_code nvarchar(5),
  protocol_definition_type	nvarchar(1),
  sort_order int,
  study_week nvarchar(20),
  pp_group nvarchar(20),
  pp_text nvarchar(120),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_RD_PROTOCOL_PROCEDURE PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_RD_PROTOCOL_PROCEDURE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_RD_PROTO_PROC_CONTAINER_INDEX ON cnprc_ehr.rd_protocol_procedure (Container);
GO