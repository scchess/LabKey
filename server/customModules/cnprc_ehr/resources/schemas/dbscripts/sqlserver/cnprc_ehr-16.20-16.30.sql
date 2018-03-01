/*
 * Copyright (c) 2016 LabKey Corporation
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

/* cnprc_ehr-16.20-16.21.sql */

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

/* cnprc_ehr-16.21-16.22.sql */

CREATE TABLE cnprc_ehr.breedingRoster (
  id int not null,
  book nvarchar(2),
  maleEnemy1 int,
  maleEnemy2 int,
  maleEnemy3 int,
  maleEnemy4 int,
  maleEnemy5 int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_BREEDING_ROSTER PRIMARY KEY (id),
  CONSTRAINT FK_BREEDING_ROSTER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE cnprc_ehr.geriatricGroups (

  id int not null,
  name nvarchar(50),
  next_pedate DATETIME,
  comment nvarchar(300),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_GERIATRIC_GROUPS PRIMARY KEY (id),
  CONSTRAINT FK_GERIATRIC_GROUPS FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

/* cnprc_ehr-16.22-16.23.sql */

CREATE INDEX BREEDING_ROSTER_CONTAINER_INDEX ON cnprc_ehr.breedingRoster (Container);
CREATE INDEX GERIATRIC_GROUPS_CONTAINER_INDEX ON cnprc_ehr.geriatricGroups (Container);
CREATE INDEX SPF_STATUS_CONTAINER_INDEX ON cnprc_ehr.spf_status (Container);
CREATE INDEX PROTOCOL_EXEMPTIONS_CONTAINER_INDEX ON cnprc_ehr.protocol_exceptions (Container);
GO

CREATE TABLE cnprc_ehr.cage_observations
(
  rowid INT IDENTITY(1,1) NOT NULL,
  date datetime,
  fulldate datetime,
  room nvarchar(100), --location or enclosure
  cage nvarchar(100),
  area nvarchar(2),
  sequence int,
  remark nvarchar(300),
  observation nvarchar(50),
  fileNum INT,
  recordType nvarchar(1),
  recordStatus nvarchar(1),
  obsCode1 nvarchar(7),
  obsCode2 nvarchar(7),
  obsCode3 nvarchar(7),
  obsCode4 nvarchar(7),
  technician nvarchar(50),
  attendant nvarchar(50),
  userid nvarchar(100),
  objectid nvarchar(100),
  taskid entityid,
  parentid entityid,
  qcstate integer,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_CAGE_OBSERVATIONS PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_CAGE_OBSERVATIONS FOREIGN KEY (container) REFERENCES core.Containers (EntityId)

);
GO

CREATE INDEX CNPRC_CAGE_OBSERVATIONS_CONTAINER_INDEX ON cnprc_ehr.cage_observations (Container);
GO

CREATE TABLE cnprc_ehr.observation_types
(
  rowid INT IDENTITY(1,1) NOT NULL,
  obsCode nvarchar(7),
  snomedCode nvarchar(7),
  pregnancyDisplayFlag nvarchar(2),
  visualSignsOnlyFlag nvarchar(2),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_OBSERVATION_TYPES PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_OBSERVATION_TYPES FOREIGN KEY (container) REFERENCES core.Containers (EntityId)

);

CREATE INDEX CNPRC_OBSERVATION_TYPES_CONTAINER_INDEX ON cnprc_ehr.observation_types (Container);
GO

CREATE TABLE cnprc_ehr.protocol (

  rowid INT IDENTITY(1,1) NOT NULL,
  protocol	nvarchar(10),
  originalProtocol	nvarchar(10),
  ciPersonId	INT,
  title	nvarchar(500),
  approved	bit,
  committeeResponseDate	datetime,
  sp1Code	nvarchar(3),
  sp1InitialAllowed	INT,
  sp1TotalAllowed	INT,
  sp2Code	nvarchar(3),
  sp2InitialAllowed	INT,
  sp2TotalAllowed	INT,
  animalAlertThreshold	float,
  aidsRelated	bit,
  phsRelated	bit,
  primateProject bit,
  protocolPainCategory	nvarchar(2),
  pairingExemption bit,
  foodExemption	bit,
  studyComment	nvarchar(MAX),
  renewProtocol	bit,
  protocolNumberYear	nvarchar(7),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PROTOCOL PRIMARY KEY (protocol),
  CONSTRAINT FK_CNPRC_EHR_PROTOCOL_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_CONTAINER_INDEX ON cnprc_ehr.protocol (Container);
GO

CREATE TABLE cnprc_ehr.formulary_dosing (

  formulary_dosing_id INT NOT NULL,
  formulary_name_fk INT,
  dosing_record_active bit,
  formulary_data_complete bit,
  drug_format_description nvarchar(50),
  concentration_units nvarchar(20),
  concentration_per_unit float,
  dose_units nvarchar(20),
  dose_per_unit float,
  dose_per_unit_min float,
  dose_per_unit_max float,
  route nvarchar(2),
  frequency nvarchar(3),
  days_duration INT,
  treatment_volume_units nvarchar(20),
  dose_specific_comment nvarchar(500),
  weight_range_lower_limit float,
  weight_range_upper_limit float,
  billing_item_code nvarchar(6),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FORMULARY_DOSING PRIMARY KEY (formulary_dosing_id),
  CONSTRAINT FK_CNPRC_EHR_FORMULARY_DOSING_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_FORMULARY_DOSING_CONTAINER_INDEX ON cnprc_ehr.formulary_dosing (Container);
GO

CREATE TABLE cnprc_ehr.formulary_name (

  formulary_name_id INT NOT NULL,
  active bit,
  generic_name nvarchar(100),
  trade_name nvarchar(100),
  name_qualifier nvarchar(100),
  category nvarchar(20),
  usage_comment	nvarchar(500),
  concentration_comment	nvarchar(500),
  dose_comment nvarchar(500),
  frequency_comment nvarchar(500),
  rx_type_c_clinical_prescrip bit,
  rx_type_l_clinical_longterm bit,
  rx_type_n_clinical_nonsched bit,
  rx_type_s_supplement bit,
  rx_type_v_vitamin bit,
  rx_type_x_experimental bit,
  rx_type_i_clinical_solitary bit,
  wide_range_therapeutic_drug bit,
  default_dose_units nvarchar(20),
  default_dose_per_unit_min float,
  default_dose_per_unit_max float,
  sort_order_within_category float, --float due to error in data, otherwise sort field should be an int
  snomed_component_1 nvarchar(7),
  snomed_component_2 nvarchar(7),
  snomed_component_3 nvarchar(7),
  snomed_component_4 nvarchar(7),
  default_billing_item_code nvarchar(6),
  include_in_formulary_book bit,
  formulary_book_comment nvarchar(800),
  formulary_book_routes nvarchar(20),
  formulary_book_frequencies nvarchar(20),
  rx_type_h_clin_supplements bit,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FORMULARY_NAME PRIMARY KEY (formulary_name_id),
  CONSTRAINT FK_CNPRC_EHR_FORMULARY_NAME_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_FORMULARY_NAME_CONTAINER_INDEX ON cnprc_ehr.formulary_name (Container);
GO

CREATE TABLE cnprc_ehr.project_charge (

  payor_id nvarchar(10) NOT NULL,
  pr_code nvarchar(5) NOT NULL,
  charge_id nvarchar(4) NOT NULL,
  fund_type nvarchar(1),
  file_status nvarchar(2) NOT NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PROJECT_CHARGE PRIMARY KEY (payor_id),
  CONSTRAINT FK_CNPRC_EHR_PROJECT_CHARGE_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_CHARGE_CONTAINER_INDEX ON cnprc_ehr.project_charge (Container);
GO

CREATE TABLE cnprc_ehr.treatment_term (

  treatment_term_id INT NOT NULL,
  term_type nvarchar(4),
  treatment_term nvarchar(20),
  definition nvarchar(80),
  snomed_component nvarchar(7),
  active bit,
  sort_order INT,
  term_comment nvarchar(120),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,
  
  CONSTRAINT PK_CNPRC_EHR_TREATMENT_TERM PRIMARY KEY (treatment_term_id),
  CONSTRAINT FK_CNPRC_EHR_TREATMENT_TERM_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_TREATMENT_TERM_CONTAINER_INDEX ON cnprc_ehr.treatment_term (Container);
GO

CREATE TABLE cnprc_ehr.protocol_amendments (

  rowid INT IDENTITY(1,1) NOT NULL,
  protocolAmendmentId INT NOT NULL,
  protocol	nvarchar(10),
  committeeResponseDate	datetime,
  approved	bit,
  sp1AdditionalAllowed	INT,
  sp2AdditonalAllowed	INT,
  amendmentComments nvarchar(MAX),
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PROTOCOL_AMENDMENTS PRIMARY KEY (protocolAmendmentId),
  CONSTRAINT FK_CNPRC_EHR_PROTOCOL_AMENDMENTS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_AMENDMENTS_CONTAINER_INDEX ON cnprc_ehr.protocol_amendments (Container);
GO

CREATE TABLE cnprc_ehr.formula_control (

  formula_control_id INT NOT NULL,
  active bit,
  concentration_units nvarchar(20),
  dose_units nvarchar(20),
  dose_by_weight bit,
  total_dose_units nvarchar(20),
  treatment_volume_units nvarchar(20),
  scaling_multiplier FLOAT,
  fc_comments nvarchar(200),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_FORMULA_CONTROL PRIMARY KEY (formula_control_id),
  CONSTRAINT FK_CNPRC_EHR_FORMULA_CONTROL_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
);
GO

CREATE INDEX CNPRC_EHR_FORMULA_CONTROL_CONTAINER_INDEX ON cnprc_ehr.formula_control (Container);
GO

/* cnprc_ehr-16.23-16.24.sql */

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

/* cnprc_ehr-16.24-16.25.sql */

CREATE TABLE cnprc_ehr.image_capture_device
(
  rowid INT IDENTITY(1,1) NOT NULL,
  device_modality nvarchar(20),
  device_type nvarchar(20),
  device_name nvarchar(50),
  description nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_CAPTURE_DEVICE PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_CAPTURE_DEVICE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_CAPTURE_DEVICE_CONTAINER_INDEX ON cnprc_ehr.image_capture_device (Container);
GO

CREATE TABLE cnprc_ehr.image_format
(
  rowid INT IDENTITY(1,1) NOT NULL,
  name nvarchar(15),
  extension nvarchar(3),
  mime_type nvarchar(20),
  description nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE_FORMAT PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_IMAGE_FORMAT FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_IMAGE_FORMAT_CONTAINER_INDEX ON cnprc_ehr.image_format (Container);
GO

CREATE TABLE cnprc_ehr.image
(
  Id nvarchar(15) NOT NULL,
  owner_type nvarchar(20),
  owner_name nvarchar(30),
  create_unit nvarchar(30),
  modality nvarchar(20),
  device_type nvarchar(20),
  device_name nvarchar(50),
  subject_type nvarchar(20),
  subject_name nvarchar(25),
  subject_location nvarchar(25),
  subject_species nvarchar(25),
  subject_organ nvarchar(25),
  original_filename nvarchar(100),
  original_format_name nvarchar(10),
  original_format_extension nvarchar(5),
  original_width_pixels  int,
  original_height_pixels int,
  original_size_bytes  int,
  upload_by nvarchar(25),
  upload_timestamp datetime,
  upload_comment nvarchar(50),
  description nvarchar(500),
  public_yn nvarchar(1),
  image_repository nvarchar(10),
  stock_yn nvarchar(1),
  stock_approved_yn nvarchar(1),
  stock_approved_by nvarchar(25),
  stock_approved_timestamp datetime,
  release_approved_yn nvarchar(1),
  release_approved_by nvarchar(25),
  release_approved_timestamp datetime,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE PRIMARY KEY (id),
  CONSTRAINT FK_CNPRC_EHR_IMAGE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_IMAGE_CONTAINER_INDEX ON cnprc_ehr.image (Container);
GO

CREATE TABLE cnprc_ehr.image_snomed
(
  rowid INT IDENTITY(1,1) NOT NULL,
  Id nvarchar(15) NOT NULL,
  snomed_pk int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE_SNOMED PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_IMAGE_SNOMED FOREIGN KEY (container) REFERENCES core.Containers (EntityId),
  UNIQUE(Id, snomed_pk)
);

CREATE INDEX CNPRC_EHR_IMAGE_SNOMED_CONTAINER_INDEX ON cnprc_ehr.image_snomed (Container);
GO

CREATE TABLE cnprc_ehr.image_pathology
(
  rowid INT IDENTITY(1,1) NOT NULL,
  Id nvarchar(15) NOT NULL,
  prm_pk int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE_NECROPSY PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_IMAGE_NECROPSY FOREIGN KEY (container) REFERENCES core.Containers (EntityId),
  UNIQUE(Id, prm_pk)
);

CREATE INDEX CNPRC_EHR_IMAGE_PATHOLOGY_CONTAINER_INDEX ON cnprc_ehr.image_snomed (Container);
GO

/* cnprc_ehr-16.25-16.26.sql */

sp_rename 'cnprc_ehr.image_pathology.PK_CNPRC_EHR_IMAGE_NECROPSY', 'PK_CNPRC_EHR_IMAGE_PATHOLOGY';
GO

sp_rename 'cnprc_ehr.FK_CNPRC_EHR_IMAGE_NECROPSY', 'FK_CNPRC_EHR_IMAGE_PATHOLOGY';
GO

DROP INDEX CNPRC_EHR_IMAGE_PATHOLOGY_CONTAINER_INDEX ON cnprc_ehr.image_snomed;
GO
CREATE INDEX CNPRC_EHR_IMAGE_PATHOLOGY_CONTAINER_INDEX ON cnprc_ehr.image_pathology (Container);
GO

ALTER TABLE cnprc_ehr.image DROP COLUMN public_yn;
GO
ALTER TABLE cnprc_ehr.image DROP COLUMN stock_yn;
GO
ALTER TABLE cnprc_ehr.image DROP COLUMN stock_approved_yn;
GO
ALTER TABLE cnprc_ehr.image DROP COLUMN release_approved_yn;
GO

ALTER TABLE cnprc_ehr.image ADD is_public bit;
GO
ALTER TABLE cnprc_ehr.image ADD is_stock bit;
GO
ALTER TABLE cnprc_ehr.image ADD is_stock_approved bit;
GO
ALTER TABLE cnprc_ehr.image ADD is_release_approved bit;
GO

/* cnprc_ehr-16.26-16.27.sql */

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

/* cnprc_ehr-16.27-16.28.sql */

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

/* cnprc_ehr-16.28-16.29.sql */

EXEC sp_rename 'cnprc_ehr.department.instituion', 'institution', 'COLUMN'

/* cnprc_ehr-16.29-16.291.sql */

ALTER TABLE cnprc_ehr.fdb_sample_checkout ADD objectid nvarchar(100);
ALTER TABLE cnprc_ehr.fdb_tissue_harvest ADD objectid nvarchar(100);
ALTER TABLE cnprc_ehr.fdb_tissue_harvest ADD notes nvarchar(100);

/* cnprc_ehr-16.291-16.292.sql */

ALTER TABLE cnprc_ehr.path_inv_blocks ADD objectid nvarchar(100);
ALTER TABLE cnprc_ehr.path_inv_checkout ADD objectid nvarchar(100);
ALTER TABLE cnprc_ehr.path_inv_fixed ADD objectid nvarchar(100);
ALTER TABLE cnprc_ehr.path_inv_frozen ADD objectid nvarchar(100);

/* cnprc_ehr-16.292-16.293.sql */

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