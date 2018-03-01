/*
 * Copyright (c) 2011-2012 LabKey Corporation
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



-- ----------------------------
-- Table structure for viral_load_assay.module_properties
-- ----------------------------
EXEC core.fn_dropifexists 'module_properties', 'viral_load_assay', 'TABLE', NULL
GO
CREATE TABLE viral_load_assay.module_properties (
    RowId INT IDENTITY(1,1) NOT NULL,

    prop_name varchar(255) DEFAULT NULL,
    stringvalue varchar(255) DEFAULT NULL,
    floatvalue float DEFAULT NULL,

    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,

    CONSTRAINT PK_module_properties PRIMARY KEY (rowId)
);

-- ----------------------------
-- Table structure for viral_load_assay.site_module_properties
-- ----------------------------
EXEC core.fn_dropifexists 'site_module_properties', 'viral_load_assay', 'TABLE', NULL
GO
CREATE TABLE viral_load_assay.site_module_properties (
    prop_name varchar(255) DEFAULT NULL,
    stringvalue varchar(255) DEFAULT NULL,
    floatvalue float DEFAULT NULL,

    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,

    CONSTRAINT PK_site_module_properties PRIMARY KEY (prop_name)
)
;
