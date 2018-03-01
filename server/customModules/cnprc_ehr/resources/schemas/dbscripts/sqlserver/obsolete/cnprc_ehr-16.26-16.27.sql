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

CREATE TABLE cnprc_ehr.path_inv_frozen
(
  path_inv_frozen_pk int,
  anseq_fk int,
  shelf nvarchar(5),
  drawer nvarchar(5),
  box	nvarchar(5),
  tissue nvarchar(1000),
  comments nvarchar(200),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PATH_INV_FROZEN PRIMARY KEY (path_inv_frozen_pk),
  CONSTRAINT FK_CNPRC_EHR_PATH_INV_FROZEN FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_FROZEN_CONTAINER_INDEX ON cnprc_ehr.path_inv_frozen (Container);
GO

CREATE TABLE cnprc_ehr.path_inv_fixed
(
  path_inv_fixed_pk int,
  anseq_fk int,
  cabinet nvarchar(5),
  bin nvarchar(5),
  comments nvarchar(200),
  check_seq_fk int,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PATH_INV_FIXED PRIMARY KEY (path_inv_fixed_pk),
  CONSTRAINT FK_CNPRC_EHR_PATH_INV_FIXED FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_FIXED_CONTAINER_INDEX ON cnprc_ehr.path_inv_fixed (Container);
GO

CREATE TABLE cnprc_ehr.path_inv_blocks
(
  path_inv_blocks_pk int,
  anseq_fk int,
  cabinet nvarchar(5),
  drawer nvarchar(5),
  tray nvarchar(5),
  tissue nvarchar(1000),
  comments nvarchar(200),
  check_seq_fk int,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PATH_INV_BLOCKS PRIMARY KEY (path_inv_blocks_pk),
  CONSTRAINT FK_CNPRC_EHR_PATH_INV_BLOCKS FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_BLOCKS_CONTAINER_INDEX ON cnprc_ehr.path_inv_blocks (Container);
GO

CREATE TABLE cnprc_ehr.path_inv_checkout
(
  path_inv_checkout_pk int,
  anseq_fk int,
  media nvarchar(25),
  checkDate	datetime,
  investigator nvarchar(100),
  comments nvarchar(500),
  returnDate datetime,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PATH_INV_CHECKOUT PRIMARY KEY (path_inv_checkout_pk),
  CONSTRAINT FK_CNPRC_EHR_PATH_INV_CHECKOUT FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_CHECKOUT_CONTAINER_INDEX ON cnprc_ehr.path_inv_checkout (Container);
GO

CREATE TABLE cnprc_ehr.fdb_sample_checkout
(
  fdb_sample_checkout_pk int,
  unit nvarchar(30),
  sample_fk int,
  thawed_date datetime,
  vials_thawed int,
  ship_location nvarchar(50),
  technician nvarchar(30),
  comments nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FDB_SAMPLE_CHECKOUT PRIMARY KEY (fdb_sample_checkout_pk),
  CONSTRAINT FK_CNPRC_EHR_FDB_SAMPLE_CHECKOUT FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_FDB_SAMPLE_CHECKOUT_CONTAINER_INDEX ON cnprc_ehr.fdb_sample_checkout (Container);
GO

CREATE TABLE cnprc_ehr.fdb_box_prefs
(
  rowid INT IDENTITY(1,1) NOT NULL,
  unit nvarchar(30),
  tank nvarchar(20),
  cane nvarchar(20),
  box nvarchar(20),
  max_box_row int,
  max_box_col int,
  max_box_size int,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FDB_BOX_PREFS PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_FDB_BOX_PREFS FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_FDB_BOX_PREFS_CONTAINER_INDEX ON cnprc_ehr.fdb_box_prefs (Container);
GO

CREATE TABLE cnprc_ehr.fdb_unit_sample_type
(
  rowid INT IDENTITY(1,1) NOT NULL,
  unit nvarchar(30),
  sample_type nvarchar(30),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FDB_UNIT_SAMP_TYPE PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_FDB_UNIT_SAMP_TYPE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_FDB_UNIT_SAMP_TYPE_CONTAINER_INDEX ON cnprc_ehr.fdb_unit_sample_type (Container);
GO

CREATE TABLE cnprc_ehr.fdb_tissue_harvest
(
  fdb_tissue_harvest_pk int,
  unit nvarchar(60),
  sample_fk int,
  tissue nvarchar(60),
  approach nvarchar(30),
  column1 nvarchar(60),
  column2 nvarchar(60),
  column3 nvarchar(60),
  column4 nvarchar(60),
  comments nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FDB_TISSUE_HARVEST PRIMARY KEY (fdb_tissue_harvest_pk),
  CONSTRAINT FK_CNPRC_EHR_FDB_TISSUE_HARVEST FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_FDB_TISSUE_HARVEST_CONTAINER_INDEX ON cnprc_ehr.fdb_tissue_harvest (Container);
GO

CREATE TABLE cnprc_ehr.fdb_samples_no_id
(
  fdb_samples_pk int,
  unit nvarchar(30),
  sample_identifier nvarchar(20),
  sample_type nvarchar(30),
  strain nvarchar(30),
  years int,
  months int,
  days int,
  gestational_age int,
  project nvarchar(20),
  cell_type nvarchar(40),
  sample_group nvarchar(20),
  age_group nvarchar(20),
  collection_date datetime,
  technician nvarchar(30),
  storage_type nvarchar(20),
  tank nvarchar(20),
  cane nvarchar(20),
  box nvarchar(20),
  location_start int,
  location_end int,
  vials int,
  vials_remaining int,
  concentration float,
  sample_volume float,
  comments nvarchar(255),
  old_pk int,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FDB_SAMPLES_NO_ID PRIMARY KEY (fdb_samples_pk),
  CONSTRAINT FK_CNPRC_EHR_FDB_SAMPLES_NO_ID FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_FDB_SAMPLES_NO_ID_CONTAINER_INDEX ON cnprc_ehr.fdb_samples_no_id (Container);
GO