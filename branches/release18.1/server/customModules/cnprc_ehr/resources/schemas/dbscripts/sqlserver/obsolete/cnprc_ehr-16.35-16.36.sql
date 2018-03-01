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
