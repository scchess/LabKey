/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

CREATE SCHEMA adjudication;

CREATE TABLE adjudication.Kit
(
  Code VARCHAR(20),
  Category VARCHAR(50),
  Description VARCHAR(500),

  CONSTRAINT PK_Kit PRIMARY KEY (Code)
);

CREATE TABLE adjudication.Status
(
  RowId SERIAL,
  Status VARCHAR(50),
  SequenceOrder INT,
  Container ENTITYID,

  CONSTRAINT PK_Status PRIMARY KEY (RowId)
);

CREATE TABLE adjudication.Adjudicator
(
  RowId SERIAL,
  Userid USERID,
  Role INT,
  Container ENTITYID,

  CONSTRAINT PK_Adjudicator PRIMARY KEY (RowId)
);

CREATE TABLE adjudication.AdjudicationCase
(
  CaseId SERIAL,
  ParticipantId VARCHAR(32),
  StatusId INT,
  Created TIMESTAMP,
  Completed TIMESTAMP,
  Notified BOOLEAN,
  AssayFileName VARCHAR(200),
  Comment VARCHAR(500),
  NewData BOOLEAN,
  LabVerified TIMESTAMP,
  Container ENTITYID,

  CONSTRAINT PK_Case PRIMARY KEY (CaseId),
  CONSTRAINT FK_Status_Status FOREIGN KEY (StatusId) REFERENCES adjudication.Status(RowId)
);

CREATE TABLE adjudication.Determination
(
  RowId SERIAL,
  CaseId INT,
  Completed TIMESTAMP,
  Status VARCHAR(50),
  Infected VARCHAR(200),
  InfectedDate TIMESTAMP,
  Comment VARCHAR(500),
  LastUpdated TIMESTAMP,
  LastUpdatedBy VARCHAR(200),
  Adjudicator INT,
  Container ENTITYID,

  CONSTRAINT PK_Determination PRIMARY KEY (RowId),
  CONSTRAINT FK_CaseId_Case FOREIGN KEY (CaseId) REFERENCES adjudication.AdjudicationCase(CaseId)
);

CREATE TABLE adjudication.Visit
(
  RowId SERIAL,
  CaseId INT,
  Visit DOUBLE PRECISION,
  Container ENTITYID,

  CONSTRAINT PK_Visit PRIMARY KEY (RowId),
  CONSTRAINT FK_CaseId_Case FOREIGN KEY (CaseId) REFERENCES adjudication.AdjudicationCase(CaseId)
);

INSERT INTO adjudication.Kit VALUES
        ('1',   'RNAPCR',             'HIV RNA Real-Time RTPCR'),
        ('002', 'Total Nucleic Acid', 'HIV-1 Total Nucleic Acid assay'),
        ('104', 'RNAPCR',             'Roche Ultra Sensitive RTPCR'),
        ('105', 'RNAPCR',             'Roche Amplicor HIV-1'),
        ('108', 'RNAPCR',             'Roche COBAS Ampliprep/COBAS Taqman HIV-1'),
        ('109', 'DNAPCR',             'Roche Amplicor HIV-1 DNA, v1.5'),
        ('204', 'EIA',                'BioRad Genetic Systems HIV 1/2 Plus O'),
        ('206', 'EIA',                'BioRad GenScreen HIV 1/2'),
        ('207', 'MULTISPOT',          'BioRad Multispot HIV-1/HIV-2 Rapid Test'),
        ('208', 'EIA',                'BioRad Genetic Systems rLAV EIA'),
        ('209', 'EIA',                'BioRad GenScreen Ultra HIV Ag-Ab HIV 1/2'),
        ('210', 'EIA',                'BioRad GS HIV Combo Ag/Ab EIA'),
        ('211', 'Geenius',            'BioRad Geenius HIV 1/2 Confirmatory Assay'),
        ('301', 'EIA',                'bioMerieux Vironostika HIV-1'),
        ('303', 'EIA',                'bioMerieux Vironostika HIV Uni-Form II + O'),
        ('306', 'EIA',                'bioMerieux Vironostika HIV Ag/Ab HIV 1/2'),
        ('402', 'EIA',                'Abbott Murex HIV-1.2.O'),
        ('403', 'EIA',                'Abbott HIV-1/HIV-2 rDNA EIA'),
        ('406', 'RNAPCR',             'Abbott m2000 Realtime PCR HIV-1'),
        ('408', 'EIA',                'Abbott Architect HIV Ag/Ab Combo');
