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
CREATE TABLE adjudication.SupportedKits
(
    RowId SERIAL,
    KitCode VARCHAR(20) NOT NULL,
    Container ENTITYID NOT NULL,
    CONSTRAINT PK_SupportedKits PRIMARY KEY (RowId),
    CONSTRAINT FK_KitCode_Kit FOREIGN KEY (KitCode) REFERENCES adjudication.Kit (Code)
);

INSERT INTO adjudication.supportedkits (KitCode, Container)
    (SELECT DISTINCT k.Code, a.Container FROM adjudication.Kit k CROSS JOIN adjudication.adjudicationcase a);