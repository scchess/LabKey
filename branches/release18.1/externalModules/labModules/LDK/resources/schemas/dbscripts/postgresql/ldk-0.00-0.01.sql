/*
 * Copyright (c) 2012 LabKey Corporation
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

CREATE SCHEMA ldk;

CREATE TABLE ldk.metrics (
    rowid SERIAL NOT NULL,
    category varchar(100) DEFAULT NULL,
    metric_name varchar(100) DEFAULT NULL,
    floatvalue1 float,
    floatvalue2 float,
    floatvalue3 float,
    stringvalue1 varchar(200) DEFAULT NULL,
    stringvalue2 varchar(200) DEFAULT NULL,
    stringvalue3 varchar(200) DEFAULT NULL,

    referrerurl varchar(4000) DEFAULT NULL,
    browser varchar(500) DEFAULT NULL,
    platform varchar(500) DEFAULT NULL,

    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_perf_metrics PRIMARY KEY (rowid)
);
