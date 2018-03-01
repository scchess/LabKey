
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

