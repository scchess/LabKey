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
/* adjudication-16.10-16.11.sql */

CREATE TABLE adjudication.AdjudicationTeamUser
(
    RowId INT IDENTITY(1,1) NOT NULL,
    AdjudicationUserId INT NOT NULL,
    TeamNumber INT NOT NULL,
    Notify BIT NOT NULL DEFAULT 1,
    Container ENTITYID NOT NULL,
    CONSTRAINT PK_AdjudicationTeamUser PRIMARY KEY (RowId),
    CONSTRAINT FK_TeamUser_User FOREIGN KEY (AdjudicationUserId) REFERENCES adjudication.AdjudicationUser (RowID),
    UNIQUE(AdjudicationUserId, TeamNumber, Container)
);

INSERT INTO adjudication.AdjudicationTeamUser (AdjudicationUserId,TeamNumber, Container)
    (SELECT adjUser.RowId, adjUser.Slot, adjUser.Container
     FROM adjudication.AdjudicationUser adjUser
     WHERE adjUser.RoleId in
           (Select Rowid from adjudication.AdjudicationRole where Name = 'Adjudicator'));

/* adjudication-16.11-16.12.sql */

DROP TABLE adjudication.AdjudicationTeamUser;

CREATE TABLE adjudication.AdjudicationTeamUser
(
  RowId INT IDENTITY(1,1) NOT NULL,
  AdjudicationUserId INT NOT NULL,
  TeamNumber INT NOT NULL,
  Notify BIT NOT NULL DEFAULT 1,
  Container ENTITYID NOT NULL,
  CONSTRAINT PK_AdjudicationTeamUser PRIMARY KEY (RowId),
  CONSTRAINT FK_TeamUser_User FOREIGN KEY (AdjudicationUserId) REFERENCES adjudication.AdjudicationUser (RowID),
  CONSTRAINT UQ_AdjudicationUserId_Container UNIQUE (AdjudicationUserId, Container)
);

INSERT INTO adjudication.AdjudicationTeamUser (AdjudicationUserId,TeamNumber, Container)
  (SELECT adjUser.RowId, adjUser.Slot, adjUser.Container
   FROM adjudication.AdjudicationUser adjUser
   WHERE adjUser.RoleId in
         (Select Rowid from adjudication.AdjudicationRole where Name = 'Adjudicator'));

EXEC core.fn_dropifexists 'AdjudicationUser', 'adjudication', 'DEFAULT', 'Slot';
ALTER TABLE adjudication.AdjudicationUser DROP COLUMN Slot;

EXEC sp_rename 'adjudication.Determination.Slot','TeamNumber', 'COLUMN';