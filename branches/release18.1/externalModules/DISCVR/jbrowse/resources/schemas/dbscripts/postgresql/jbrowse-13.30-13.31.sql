/*
 * Copyright (c) 2014 LabKey Corporation
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

-- Create schema, tables, indexes, and constraints used for JBrowse module here
-- All SQL VIEW definitions should be created in jbrowse-create.sql and dropped in jbrowse-drop.sql
CREATE SCHEMA jbrowse;

CREATE TABLE jbrowse.jsonfiles (
  trackid int,
  relpath varchar(1000),
  objectid entityid,

  container entityid,
  created timestamp,
  createdby int,
  modified timestamp,
  modifiedby int,

  CONSTRAINT PK_jsonfiles PRIMARY KEY (objectid)
);

CREATE TABLE jbrowse.databases (
  rowid serial,
  name varchar(100),
  description varchar(4000),
  objectid entityid,

  container entityid,
  created timestamp,
  createdby int,
  modified timestamp,
  modifiedby int,

  CONSTRAINT PK_databases PRIMARY KEY (objectid)
);

CREATE TABLE jbrowse.database_members (
  rowid serial,
  database entityid,
  jsonfile entityid,

  container entityid,
  created timestamp,
  createdby int,
  modified timestamp,
  modifiedby int,

  CONSTRAINT PK_database_members PRIMARY KEY (rowid)
);