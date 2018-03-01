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
/* adjudication-15.20-15.21.sql */

CREATE SCHEMA adjudication;
GO
CREATE SCHEMA adjudicationtables;
GO

CREATE TABLE adjudication.Kit
(
  Code NVARCHAR(20),
  Category NVARCHAR(50),
  Description NVARCHAR(500),

  CONSTRAINT PK_adjudication_Kit PRIMARY KEY (Code)
);

CREATE TABLE adjudication.Status
(
  RowId INT IDENTITY(1,1) NOT NULL,
  Status NVARCHAR(50),
  SequenceOrder INT,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_adjudication_Status PRIMARY KEY (RowId)
);

CREATE TABLE adjudication.Adjudicator
(
  RowId INT IDENTITY(1,1) NOT NULL,
  Userid USERID,
  Role INT,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_adjudication_Adjudicator PRIMARY KEY (RowId)
);

CREATE TABLE adjudication.AdjudicationCase
(
  CaseId INT IDENTITY(1,1) NOT NULL,
  ParticipantId VARCHAR(32),
  StatusId INT,
  Created DATETIME,
  Completed DATETIME,
  Notified BIT NOT NULL DEFAULT 0,
  AssayFileName NVARCHAR(200),
  Comment NVARCHAR(500),
  NewData BIT NOT NULL DEFAULT 0,
  LabVerified DATETIME,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_adjudication_AdjudicationCase PRIMARY KEY (CaseId),
  CONSTRAINT FK_adjudication_StatusId_Status FOREIGN KEY (StatusId) REFERENCES adjudication.Status(RowId)
);

CREATE TABLE adjudication.Determination
(
  RowId INT IDENTITY(1,1) NOT NULL,
  CaseId INT,
  Completed DATETIME,
  Status NVARCHAR(50),
  Infected NVARCHAR(200),
  InfectedDate DATETIME,
  Comment NVARCHAR(500),
  LastUpdated DATETIME,
  LastUpdatedBy NVARCHAR(200),
  Adjudicator INT,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_adjudication_Determination PRIMARY KEY (RowId),
  CONSTRAINT FK_adjudication_AdjudicationCaseId_Case FOREIGN KEY (CaseId) REFERENCES adjudication.AdjudicationCase(CaseId)
);

CREATE TABLE adjudication.Visit
(
  RowId INT IDENTITY(1,1) NOT NULL,
  CaseId INT,
  Visit FLOAT,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_adjudication_Visit PRIMARY KEY (RowId),
  CONSTRAINT FK_adjudication_AdjudicationCaseId_Case1 FOREIGN KEY (CaseId) REFERENCES adjudication.AdjudicationCase(CaseId)
);
GO

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
GO

/* adjudication-15.21-15.22.sql */

DROP TABLE adjudication.Adjudicator
GO

ALTER TABLE adjudication.Determination DROP COLUMN Infected;
ALTER TABLE adjudication.Determination DROP COLUMN InfectedDate;
ALTER TABLE adjudication.Determination DROP COLUMN Comment;

ALTER TABLE adjudication.Determination ADD Hiv1Infected NVARCHAR(200);
ALTER TABLE adjudication.Determination ADD Hiv2Infected NVARCHAR(200);
ALTER TABLE adjudication.Determination ADD Hiv1InfDate DATETIME;
ALTER TABLE adjudication.Determination ADD Hiv2InfDate DATETIME;
ALTER TABLE adjudication.Determination ADD Hiv1Comment NVARCHAR(500);
ALTER TABLE adjudication.Determination ADD Hiv2Comment NVARCHAR(500);

/* adjudication-15.22-15.23.sql */

ALTER TABLE adjudication.Determination DROP COLUMN Hiv1InfDate;
ALTER TABLE adjudication.Determination DROP COLUMN Hiv2InfDate;

ALTER TABLE adjudication.Determination ADD Hiv1InfectedVisit FLOAT;
ALTER TABLE adjudication.Determination ADD Hiv2InfectedVisit FLOAT;

EXEC sp_rename 'adjudication.Determination.Adjudicator', 'AdjudicatorUserId', 'COLUMN'