/*
 * Copyright (c) 2013 LabKey Corporation
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

CREATE SCHEMA labkey;
GO

CREATE TABLE labkey.Schemas
(
    CreatedBy INT,
    Created DATETIME,
    ModifiedBy INT,
    Modified DATETIME,

    Name NVARCHAR(255) NOT NULL,
    ModuleName NVARCHAR(255) NOT NULL,
    InstalledVersion FLOAT NOT NULL,

    CONSTRAINT PK_Schemas PRIMARY KEY (Name)
);

CREATE TABLE labkey.SqlScripts
(
    CreatedBy INT,
    Created DATETIME,
    ModifiedBy INT,
    Modified DATETIME,

    ModuleName NVARCHAR(255) NOT NULL,
    FileName NVARCHAR(300) NOT NULL,

    CONSTRAINT PK_SqlScripts PRIMARY KEY (ModuleName, FileName)
);
