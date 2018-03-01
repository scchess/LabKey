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

/* adjudication-15.30-15.31.sql */

CREATE PROCEDURE adjudication.handleUpgrade AS
    BEGIN
    IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'adjudicationtables')
        BEGIN
            execute('CREATE SCHEMA [adjudicationtables]');
        END
    END;

GO

EXEC adjudication.handleUpgrade
GO

DROP PROCEDURE adjudication.handleUpgrade
GO

/* adjudication-15.31-15.32.sql */

CREATE TABLE adjudication.AdjudicationRole (
  RowId INT IDENTITY(1,1) NOT NULL,
  Name VARCHAR(100) NOT NULL ,
  CONSTRAINT PK_AdjudicationRole PRIMARY KEY (RowId)
)
GO

CREATE TABLE adjudication.AdjudicationUser (
  RowId INT IDENTITY(1,1) NOT NULL,
  UserId USERID NOT NULL,
  RoleId INT NOT NULL,
  Slot INT DEFAULT NULL,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_AdjudicationUser PRIMARY KEY (RowId),
  CONSTRAINT FK_RoleId_Role FOREIGN KEY (RoleId) REFERENCES adjudication.AdjudicationRole(RowId),
  UNIQUE (UserId, Container)
)
GO

INSERT INTO adjudication.AdjudicationRole (Name) VALUES
  ('Lab Personnel'), ('Adjudicator'), ('To Be Notified')
GO

EXEC sp_rename 'adjudication.Determination.AdjudicatorUserId', 'Slot', 'COLUMN';

EXEC core.executeJavaUpgradeCode 'populateAdjudicationUserAndUpdateDetermination';

/* adjudication-15.32-15.33.sql */

CREATE TABLE adjudication.SupportedKits
(
    RowId INT IDENTITY(1,1) NOT NULL,
    KitCode NVARCHAR(20) NOT NULL,
    Container ENTITYID NOT NULL,
    CONSTRAINT PK_SupportedKits PRIMARY KEY (RowId),
    CONSTRAINT FK_KitCode_Kit FOREIGN KEY (KitCode) REFERENCES adjudication.Kit (Code)
);

INSERT INTO adjudication.supportedkits (KitCode, Container)
    (SELECT DISTINCT k.Code, a.Container FROM adjudication.Kit k CROSS JOIN adjudication.adjudicationcase a);

/* adjudication-15.33-15.34.sql */

UPDATE core.RoleAssignments SET Role = 'org.labkey.adjudication.security.AdjudicatorRole' WHERE Role = 'org.labkey.adjudication.AdjudicatorRole'
UPDATE core.RoleAssignments SET Role = 'org.labkey.adjudication.security.AdjudicationLabPersonnelRole' WHERE Role = 'org.labkey.adjudication.AdjudicationLabPersonnelRole'

/* adjudication-15.34-15.35.sql */

INSERT INTO adjudication.AdjudicationRole (Name) VALUES ('Infection Monitor'), ('Data Reviewer')

/* adjudication-15.35-15.36.sql */

INSERT INTO adjudication.AdjudicationRole (Name) VALUES ('Folder Administrator')