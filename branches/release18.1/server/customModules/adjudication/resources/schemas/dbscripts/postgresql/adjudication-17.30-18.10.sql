/* adjudication-17.30-17.31.sql */

CREATE TABLE adjudication.AssayType
(
    RowId SERIAL,
    Name VARCHAR(200) NOT NULL,
    Label VARCHAR(200) NOT NULL,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP,
    Modified TIMESTAMP,
    CreatedBy USERID,
    ModifiedBy USERID,

    CONSTRAINT PK_AssayTypes PRIMARY KEY (RowId),
    CONSTRAINT UQ_Name_Container UNIQUE (Container, Name)
);

SELECT core.executeJavaUpgradeCode('populateRootDefaultAssayTypes');

/* adjudication-17.31-17.32.sql */

ALTER TABLE adjudication.AssayType ALTER COLUMN label DROP NOT NULL;

/* adjudication-17.32-17.33.sql */

CREATE UNIQUE INDEX ix_name_lower_unique ON adjudication.assaytype (Container, LOWER(Name));