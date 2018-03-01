/*
 * Copyright (c) 2012-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/* EHR-12.21-12.22.sql */

CREATE TABLE ehr.chargedItems (
    rowid INT IDENTITY (1,1) NOT NULL,
    id varchar(100),
    date DATETIME,
    debitedaccount varchar(100),
    creditedaccount varchar(100),
    category varchar(100),
    item varchar(500),
    quantity double precision,
    unitcost double precision,
    totalcost double precision,
    comment varchar(4000),
    flag integer,

    container ENTITYID NOT NULL,
    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_charged_items PRIMARY KEY (RowId)
);

ALTER TABLE ehr.snomed_tags ADD schemaName varchar(100);
ALTER TABLE ehr.snomed_tags ADD queryName varchar(100);
ALTER TABLE ehr.snomed_tags ADD qualifier varchar(200);
ALTER TABLE ehr.snomed_tags ADD sort integer;

CREATE TABLE ehr.accounts (
    account varchar(100),
    "grant" varchar(100),
    investigator integer,
    startdate DATETIME,
    enddate DATETIME,
    externalid varchar(200),
    comment varchar(4000),
    tier integer,

    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_accounts PRIMARY KEY (account)
);

CREATE TABLE ehr.investigators (
    RowId  int identity(1,1) NOT NULL,
    FirstName varchar(100),
    LastName varchar(100),
    Position varchar(100),
    Address varchar(500),
    City varchar(100),
    State varchar(100),
    Country varchar(100),
    ZIP integer,
    PhoneNumber varchar(100),
    InvestigatorType varchar(100),
    EmailAddress varchar(100),
    DateCreated datetime,
    DateDisabled datetime,
    Division varchar(100),

    --container entityid,
    createdby userid,
    created datetime,
    modifiedby userid,
    modified datetime,
    CONSTRAINT pk_investigators PRIMARY KEY (rowid)
);

/* EHR-12.22-12.23.sql */

--user / role for a given procedure
CREATE TABLE ehr.encounter_participants (
  rowid int identity(1,1),
  userid int,
  username varchar(500),
  role varchar(200),
  procedure_id entityid,
  comment varchar(4000),
  container entityid NOT NULL,
  createdby userid,
  created datetime,
  modifiedby userid,
  modified datetime,

  constraint pk_encounter_participants PRIMARY KEY (rowid)
);


ALTER TABLE ehr.protocol add enddate datetime;
ALTER TABLE ehr.protocol add title varchar(1000);
ALTER TABLE ehr.protocol add usda_level varchar(100);
ALTER TABLE ehr.protocol add external_id varchar(200);
ALTER TABLE ehr.protocol add project_type varchar(200);
ALTER TABLE ehr.protocol add ibc_approval_required bit;
ALTER TABLE ehr.protocol add ibc_approval_num varchar(200);

ALTER table ehr.project drop column requestid;

/* EHR-12.23-12.24.sql */

EXEC core.executeJavaUpgradeCode 'modifyStudyColumns1';

/* EHR-12.26-12.27.sql */

DROP table ehr.site_module_properties;
DROP table ehr.automatic_alerts;

/* EHR-12.27-12.28.sql */

ALTER TABLE ehr.animal_groups add category varchar(100);
ALTER TABLE ehr.animal_groups drop column container;

CREATE TABLE ehr.animal_group_members (
  rowid int identity(1,1),
  date datetime,
  enddate datetime,
  groupname integer,
  comment varchar(4000),

  objectid entityid,
  container entityid NOT NULL,
  createdby userid,
  created datetime,
  modifiedby userid,
  modified datetime,

  constraint pk_animal_group_members PRIMARY KEY (rowid)
);

CREATE TABLE ehr.scheduled_tasks (
  rowid int identity(1,1),
  taskid ENTITYID NOT NULL,
  tasktype varchar(200),
  date datetime,
  enddate datetime,
  frequency int,
  id varchar(100),
  location varchar(100),
  description varchar(4000),
  json text,

  objectid entityid,
  container entityid NOT NULL,
  createdby userid,
  created datetime,
  modifiedby userid,
  modified datetime,

  constraint pk_scheduled_tasks PRIMARY KEY (rowid)
);

CREATE TABLE ehr.scheduled_task_types (
  tasktype varchar(200),

  constraint pk_scheduled_task_types PRIMARY KEY (tasktype)
);

ALTER TABLE ehr.encounter_participants add objectid ENTITYID;

/* EHR-12.28-12.29.sql */

ALTER TABLE ehr.project add contact_emails varchar(4000);
ALTER TABLE ehr.project DROP COLUMN qcstate;