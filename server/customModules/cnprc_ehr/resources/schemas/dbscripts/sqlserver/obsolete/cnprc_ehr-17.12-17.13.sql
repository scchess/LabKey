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
ALTER TABLE ehr.project DROP COLUMN unitCode;
GO

CREATE TABLE cnprc_ehr.project (

  rowid INT IDENTITY(1,1) NOT NULL,
  project_tracking_id nvarchar(6),
  pp_id int,
  projectCode nvarchar(5),
  an_requested_per_year nvarchar(30),
  an_used_assigned nvarchar(30),
  protocol nvarchar(10),
  unitCode nvarchar(6),
  date_protocol_sub_aucaac DATETIME,
  direct_amt_received float,
  direct_amt_requested_1 float,
  direct_amt_requested_2 float,
  funding_agency_1 nvarchar(14),
  funding_agency_2 nvarchar(14),
  grant_contract_id nvarchar(12),
  oi_department nvarchar(12),
  oi_name nvarchar(12),
  pi_department nvarchar(12),
  pi_name nvarchar(12),
  attributes nvarchar(44),
  startdate DATETIME,
  comments nvarchar(60),
  enddate DATETIME,
  tb_exempt_flag nvarchar(1),
  title nvarchar(60),
  tracking_status nvarchar(2),
  proposed_end_date DATETIME,
  proposed_start_date DATETIME,
  protocol_end_date DATETIME,
  protocol_response_date DATETIME,
  sp_requested nvarchar(30),
  total_animals int,
  visual_signs_auto_rpt_flag nvarchar(1),
  is_prpt_recognized bit,
  pi_affiliation nvarchar(2),
  oi_affiliation nvarchar(2),
  is_tissue_avail bit,
  pi_person_fk int,
  research bit,
  projectType int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_PROJECT PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_PROJECT_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
);

CREATE INDEX CNPRC_EHR_PROJECT_CONTAINER_INDEX ON cnprc_ehr.project (Container);
CREATE INDEX CNPRC_EHR_PROJECT_OBJECTID_INDEX ON cnprc_ehr.project (objectid);
GO
