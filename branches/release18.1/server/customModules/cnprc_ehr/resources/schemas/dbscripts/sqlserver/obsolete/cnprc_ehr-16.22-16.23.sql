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