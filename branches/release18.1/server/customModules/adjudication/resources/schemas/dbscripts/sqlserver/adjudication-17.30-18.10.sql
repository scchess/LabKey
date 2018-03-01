/* adjudication-17.30-17.31.sql */

CREATE TABLE adjudication.AssayType
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Label NVARCHAR(200) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,
    CreatedBy USERID,
    ModifiedBy USERID,

    CONSTRAINT PK_AssayTypes PRIMARY KEY (RowId),
    CONSTRAINT UQ_Name_Container UNIQUE (Container, Name)
);
GO

EXEC core.executeJavaUpgradeCode 'populateRootDefaultAssayTypes';

/* adjudication-17.31-17.32.sql */

ALTER TABLE adjudication.AssayType ALTER COLUMN label NVARCHAR(200) NULL;