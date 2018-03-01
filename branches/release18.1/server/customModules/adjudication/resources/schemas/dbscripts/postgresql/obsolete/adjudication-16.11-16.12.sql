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
DROP TABLE adjudication.adjudicationteamuser;

CREATE TABLE adjudication.adjudicationteamuser
(
  rowid serial NOT NULL,
  adjudicationuserid userid NOT NULL,
  teamnumber integer NOT NULL,
  notify boolean default true,
  container entityid NOT NULL,
  CONSTRAINT pk_adjudicationteamuser PRIMARY KEY (rowid),
  CONSTRAINT fk_userid_user FOREIGN KEY (adjudicationuserid)
  REFERENCES adjudication.adjudicationuser (rowid),
  CONSTRAINT uq_adjudicationuserid_container UNIQUE (adjudicationuserid, container)
);

INSERT INTO adjudication.adjudicationTeamUser (AdjudicationUserId,TeamNumber, Container)
  (SELECT adjUser.RowId, adjUser.Slot, adjUser.Container
   FROM adjudication.adjudicationUser adjUser
   WHERE adjUser.RoleId in
         (Select Rowid from adjudication.adjudicationRole where Name = 'Adjudicator'));

ALTER TABLE adjudication.adjudicationUser DROP COLUMN Slot;

ALTER TABLE adjudication.Determination RENAME COLUMN Slot TO TeamNumber;

