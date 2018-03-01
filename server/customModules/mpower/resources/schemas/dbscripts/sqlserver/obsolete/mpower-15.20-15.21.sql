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
CREATE SCHEMA mpower;
GO

CREATE TABLE mpower.Participant
(
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    RowId INT IDENTITY(1, 1) NOT NULL,
    LastName NVARCHAR(64),
    FirstName NVARCHAR(64),
    BirthDate DATETIME,

    CONSTRAINT PK_RequestStatus PRIMARY KEY (RowId),
    CONSTRAINT UQ_RequestStatus UNIQUE (LastName, FirstName, BirthDate, Container)
);

CREATE TABLE mpower.ParticipantResponseMap
(
    Created DATETIME,
    Modified DATETIME,

    ParticipantId INT NOT NULL,
    GUID ENTITYID NOT NULL,

    CONSTRAINT PK_ParticipantResponseMap PRIMARY KEY (ParticipantId, GUID),
    CONSTRAINT FK_ParticipantId_Participant FOREIGN KEY (ParticipantId) REFERENCES mpower.Participant(RowId)
);

CREATE TABLE mpower.SurveyResponse
(
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    RowId INT IDENTITY(1, 1) NOT NULL,
    GUID ENTITYID NOT NULL,
    SurveyDesignId INT NOT NULL,

    CONSTRAINT PK_SurveyResponse PRIMARY KEY (RowId)
);

