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

/* cnprc_ehr-16.30-16.31.sql */

drop table cnprc_ehr.project_charge;

/* cnprc_ehr-16.31-16.32.sql */

CREATE TABLE cnprc_ehr.center_unit
(
  rowid INT IDENTITY(1,1) NOT NULL,
  center_unit_seqpk int,
  center_unit_code nvarchar(6),
  center_unit_title nvarchar(60),
  center_unit_department int,
  center_unit_comment nvarchar(1000),
  center_unit_active nvarchar(1),
  center_unit_key int,
  center_unit_record_class nvarchar(4),
  general_reports_sort_order int,
  grant_reports_sort_order int,
  financial_rpts_routed_to_cp_fk int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_CENTER_UNIT PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_CENTER_UNIT_CONTAINER FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_CENTER_UNIT_CONTAINER_INDEX ON cnprc_ehr.center_unit (Container);
GO

/* cnprc_ehr-16.32-16.33.sql */

DROP TABLE cnprc_ehr.persons;
GO

/* cnprc_ehr-16.33-16.34.sql */

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

/* cnprc_ehr-16.34-16.35.sql */

CREATE INDEX CNPRC_EHR_CAGE_OBSERVATIONS_OBJECTID_INDEX ON cnprc_ehr.cage_observations (objectid);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_EXCEPTIONS_OBJECTID_INDEX ON cnprc_ehr.protocol_exceptions (objectid);
GO

CREATE INDEX CNPRC_EHR_BREEDING_ROSTER_OBJECTID_INDEX ON cnprc_ehr.breedingRoster (objectid);
GO

CREATE INDEX CNPRC_EHR_GERIATRIC_GROUPS_OBJECTID_INDEX ON cnprc_ehr.geriatricGroups (objectid);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_OBJECTID_INDEX ON cnprc_ehr.protocol (objectid);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_AMENDMENTS_OBJECTID_INDEX ON cnprc_ehr.protocol_amendments (objectid);
GO

CREATE INDEX CNPRC_EHR_IMAGE_OBJECTID_INDEX ON cnprc_ehr.image (objectid);
GO

CREATE INDEX CNPRC_EHR_IMAGE_SNOMED_OBJECTID_INDEX ON cnprc_ehr.image_snomed (objectid);
GO

CREATE INDEX CNPRC_EHR_IMAGE_PATHOLOGY_OBJECTID_INDEX ON cnprc_ehr.image_pathology (objectid);
GO

CREATE INDEX CNPRC_EHR_FDB_SAMPLE_CHECKOUT_OBJECTID_INDEX ON cnprc_ehr.fdb_sample_checkout (objectid);
GO

CREATE INDEX CNPRC_EHR_FDB_TISSUE_HARVEST_OBJECTID_INDEX ON cnprc_ehr.fdb_tissue_harvest (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_BLOCKS_OBJECTID_INDEX ON cnprc_ehr.path_inv_blocks (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_CHECKOUT_OBJECTID_INDEX ON cnprc_ehr.path_inv_checkout (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_FIXED_OBJECTID_INDEX ON cnprc_ehr.path_inv_fixed (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_FROZEN_OBJECTID_INDEX ON cnprc_ehr.path_inv_frozen (objectid);
GO

CREATE INDEX CNPRC_EHR_KEY_ASSIGNMENTS_OBJECTID_INDEX ON cnprc_ehr.key_assignments (objectid);
GO

CREATE INDEX CNPRC_EHR_KEYS_OBJECTID_INDEX ON cnprc_ehr.keys (objectid);
GO

CREATE INDEX CNPRC_EHR_MH_FILE_OBJECTID_INDEX ON cnprc_ehr.mh_file (objectid);
GO

CREATE INDEX CNPRC_EHR_MH_DUMP_OBJECTID_INDEX ON cnprc_ehr.mh_dump (objectid);
GO

CREATE INDEX CNPRC_EHR_CENTER_UNIT_OBJECTID_INDEX ON cnprc_ehr.center_unit (objectid);
GO

/* cnprc_ehr-16.35-16.36.sql */

CREATE TABLE cnprc_ehr.conceptions(

  rowid INT IDENTITY(1,1) NOT NULL,
	Id nvarchar(5),
  femaleSpecies nvarchar(3),
  sire nvarchar(5),
  maleSpecies nvarchar(3),
  offspringId nvarchar(5),
  offspringSpecies nvarchar(3),
  birthViability nvarchar(1),
  deathType nvarchar(2),
  necropsyPerformed nvarchar(1),
  pathologist nvarchar(12),
  birthPlace nvarchar(9),
  gender nvarchar(1),
  deliveryMode nvarchar(2),
  pgFlag nvarchar(1),
  conNum nvarchar(8),
  conception DATETIME,
  conceptionDateStatus nvarchar(1),
  con_accession_date DATETIME,
  brType nvarchar(1),
  colonyCode nvarchar(1),
  prCode nvarchar(5),
  pgComment nvarchar(14),
  termDate DATETIME,
  termDateStatus nvarchar(1),
  termComment nvarchar(48),
  birthPlacePrefix nvarchar(4),
  pgType nvarchar(2),
  femaleGeneticsVerify nvarchar(1),
  maleGeneticsVerify nvarchar(1),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_CONCEPTIONS PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_CONCEPTIONS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE INDEX CNPRC_EHR_CONCEPTIONS_CONTAINER_INDEX ON cnprc_ehr.conceptions (Container);
GO

CREATE INDEX CNPRC_EHR_CONCEPTIONS_OBJECTID_INDEX ON cnprc_ehr.conceptions (objectid);
GO

/* cnprc_ehr-16.36-16.37.sql */

ALTER TABLE cnprc_ehr.cage_location_history ADD cage_size_number INT;

/* cnprc_ehr-16.37-16.38.sql */

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

/* cnprc_ehr-16.38-16.39.sql */

ALTER TABLE cnprc_ehr.room_enclosure ADD indoorOutdoorFlag nvarchar(1);
GO

/* cnprc_ehr-16.39-16.391.sql */

ALTER TABLE cnprc_ehr.keys DROP COLUMN number;
ALTER TABLE cnprc_ehr.keys ADD key_number nvarchar(15);