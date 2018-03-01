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
TRUNCATE TABLE ehr.protocol;

ALTER TABLE cnprc_ehr.project DROP COLUMN projectType;
ALTER TABLE cnprc_ehr.project DROP COLUMN research;
ALTER TABLE cnprc_ehr.project DROP COLUMN pp_id;

ALTER TABLE cnprc_ehr.protocol ADD piPersonId	int;
ALTER TABLE cnprc_ehr.protocol ADD protocolBeginDate datetime;
ALTER TABLE cnprc_ehr.protocol ADD protocolEndDate datetime;
ALTER TABLE cnprc_ehr.protocol ADD projectType int;

CREATE TABLE cnprc_ehr.project_protocol (

  pp_pk int,
  projectCode nvarchar(10),
  protocol_number nvarchar(10),
  pp_assignment_date datetime,
  pp_release_date datetime,
  objectid nvarchar(100),
  Created datetime,
  CreatedBy userid,
  Modified datetime,
  ModifiedBy userid,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_PROJECT_PROTOCOL PRIMARY KEY (pp_pk),
  CONSTRAINT FK_CNPRC_PROJECT_PROTOCOL_CONTAINER FOREIGN KEY (container) REFERENCES core.Containers (EntityId)

);
GO

CREATE INDEX CNPRC_PROJECT_PROTOCOL_CONTAINER_INDEX ON cnprc_ehr.project_protocol (Container);
CREATE INDEX CNPRC_PROJECT_PROTOCOL_OBJECTID_INDEX ON cnprc_ehr.project_protocol (objectid);
GO
