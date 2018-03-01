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

CREATE TABLE adjudication.AdjudicationRole (
  RowId SERIAL,
  Name VARCHAR(100) NOT NULL ,
  CONSTRAINT PK_AdjudicationRole PRIMARY KEY (RowId)
);

CREATE TABLE adjudication.AdjudicationUser (
  RowId SERIAL,
  UserId USERID NOT NULL,
  RoleId INT NOT NULL,
  Slot INT DEFAULT NULL,
  Container ENTITYID NOT NULL,

  CONSTRAINT PK_AdjudicationUser PRIMARY KEY (RowId),
  CONSTRAINT FK_RoleId_Role FOREIGN KEY (RoleId) REFERENCES adjudication.AdjudicationRole(RowId),
  UNIQUE (UserId, Container)
);

INSERT INTO adjudication.AdjudicationRole (Name) VALUES
  ('Lab Personnel'), ('Adjudicator'), ('To Be Notified');

ALTER TABLE adjudication.Determination RENAME COLUMN AdjudicatorUserId TO Slot;

SELECT core.executeJavaUpgradeCode('populateAdjudicationUserAndUpdateDetermination');
