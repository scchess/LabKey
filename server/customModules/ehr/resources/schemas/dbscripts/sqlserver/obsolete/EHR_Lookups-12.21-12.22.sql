/*
 * Copyright (c) 2012-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
CREATE TABLE ehr_lookups.charge_flags (
    rowid INT IDENTITY (1,1) NOT NULL,
    shortName varchar(100),
    description varchar(4000),

    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_charge_flags PRIMARY KEY (RowId)
);

CREATE TABLE ehr_lookups.account_tiers (
    rowid INT IDENTITY(1,1) NOT NULL,
    meaning varchar(200),
    multiplier double precision,

    createdBy USERID,
    created DATETIME,
    modifiedBy USERID,
    modified DATETIME,

    CONSTRAINT PK_account_tiers PRIMARY KEY (rowid)
);