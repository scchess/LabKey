/*
 * Copyright (c) 2012-2014 LabKey Corporation
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

/* targetedms-0.00-0.01.sql */

-- Create schema, tables, indexes, and constraints used for TargetedMS module here
-- All SQL VIEW definitions should be created in targetedms-create.sql and dropped in targetedms-drop.sql
CREATE SCHEMA targetedms;

CREATE TABLE targetedms.Runs
(
    _ts TIMESTAMP DEFAULT now(),
    Id SERIAL NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,
    Owner USERID NULL,

    Container ENTITYID NOT NULL,
    EntityId ENTITYID NOT NULL,
    Description VARCHAR(300),
    Path VARCHAR(500),
    FileName VARCHAR(300),
    Status VARCHAR(200),
    StatusId INT NOT NULL DEFAULT 0,
    Deleted BOOLEAN NOT NULL DEFAULT '0',
    ExperimentRunLSID LSIDType NULL,

    PeptideGroupCount INT NOT NULL DEFAULT 0,
    PeptideCount INT NOT NULL DEFAULT 0,
    PrecursorCount INT NOT NULL DEFAULT 0,
    TransitionCount INT NOT NULL DEFAULT 0,

    CONSTRAINT PK_Runs PRIMARY KEY (Id)
);



-- ----------------------------------------------------------------------------
-- Transition Settings
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Predictor
(
    Id SERIAL NOT NULL,
    Name VARCHAR(100),
    StepSize INT,
    StepCount INT,
    Charge INT,
    Slope REAL,
    Intercept REAL,

    CONSTRAINT PK_Predictor PRIMARY KEY (Id)
);

CREATE TABLE targetedms.TransitionPredictionSettings
(
    RunId INT NOT NULL,
    PrecursorMassType VARCHAR(5),
    ProductMassType VARCHAR(5),
    OptimizeBy VARCHAR(10) NOT NULL,
    CePredictorId INT,
    DpPredictorId INT,

    CONSTRAINT PK_TransitionPredictionSettings PRIMARY KEY (RunId),
    CONSTRAINT FK_TransitionPredictionSettings_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE TABLE targetedms.TransitionInstrumentSettings
(
    RunId INT NOT NULL,
    DynamicMin BOOLEAN,
    MinMz INT NOT NULL,
    MaxMz INT NOT NULL,
    MzMatchTolerance REAL NOT NULL,
    MinTime INT,
    MaxTime INT,
    MaxTransitions INT,

    CONSTRAINT PK_TransitionInstrumentSettings PRIMARY KEY (RunId),
    CONSTRAINT FK_TransitionInstrumentSettings_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE TABLE targetedms.TransitionFullScanSettings
(
    RunId INT NOT NULL,
    PrecursorFilter REAL,
    PrecursorLeftFilter REAL,
    PrecursorRightFilter REAL,
    ProductMassAnalyzer VARCHAR(20),
    ProductRes REAL,
    ProductResMz REAL,
    PrecursorIsotopes VARCHAR(10),
    PrecursorIsotopeFilter REAL,
    PrecursorMassAnalyzer VARCHAR(20),
    PrecursorRes REAL,
    PrecursorResMz REAL,
    ScheduleFilter BOOLEAN,

    CONSTRAINT PK_TransitionFullScanSettings PRIMARY KEY (RunId),
    CONSTRAINT FK_TransitionFullScanSettings_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE TABLE targetedms.IsotopeEnrichment
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Symbol VARCHAR(10),
    PercentEnrichment REAL,

    CONSTRAINT PK_IsotopeEnrichment PRIMARY KEY (Id),
    CONSTRAINT FK_IsotopeEnrichment_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);
CREATE INDEX IX_IsotopeEnrichment_RunId ON targetedms.IsotopeEnrichment (RunId);



-- ----------------------------------------------------------------------------
-- Peptide Settings
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.RetentionTimePredictionSettings
(
    RunId INT NOT NULL,
    CalculatorName VARCHAR(100),
    IsIrt BOOLEAN,
    RegressionSlope REAL,
    RegressionIntercept REAL,

    CONSTRAINT PK_RetentionTimePredictionSettings PRIMARY KEY (RunId),
    CONSTRAINT FK_RetentionTimePredictionSettings_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);



-- ----------------------------------------------------------------------------
-- Instrument, Replicate and SampleFile
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Instrument
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Model VARCHAR(300),
    IonizationType VARCHAR(300),
    Analyzer VARCHAR(300),
    Detector VARCHAR(300),

    CONSTRAINT PK_Instrument PRIMARY KEY (Id),
    CONSTRAINT FK_Instrument_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE INDEX IX_Instrument_RunId ON targetedms.Instrument (RunId);

CREATE TABLE targetedms.Replicate
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    CePredictorId INT,
    DpPredictorId INT,

    CONSTRAINT PK_Replicate PRIMARY KEY (Id),
    CONSTRAINT FK_Replicate_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id),
    CONSTRAINT FK_Replicate_PredictorCe FOREIGN KEY (CePredictorId) REFERENCES targetedms.Predictor(Id),
    CONSTRAINT FK_Replicate_PredictorDp FOREIGN KEY (DpPredictorId) REFERENCES targetedms.Predictor(Id)
);

CREATE INDEX IX_Replicate_RunId ON targetedms.Replicate(RunId);
CREATE INDEX IX_Replicate_CePredictorId ON targetedms.Replicate(CePredictorId);
CREATE INDEX IX_Replicate_DpPredictorId ON targetedms.Replicate(DpPredictorId);

CREATE TABLE targetedms.SampleFile
(
    Id SERIAL NOT NULL,
    ReplicateId INT NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    SampleName VARCHAR(300) NOT NULL,
    SkylineId VARCHAR(300) NOT NULL,
    AcquiredTime TIMESTAMP,
    ModifiedTime TIMESTAMP,
    InstrumentId INT,

    CONSTRAINT PK_SampleFile PRIMARY KEY (Id),
    CONSTRAINT FK_SampleFile_Replicate FOREIGN KEY (ReplicateId) REFERENCES targetedms.Replicate(Id),
    CONSTRAINT FK_SampleFile_Instrument FOREIGN KEY (InstrumentId) REFERENCES targetedms.Instrument(Id)
);

CREATE INDEX IX_SampleFile_ReplicateId ON targetedms.SampleFile(ReplicateId);



-- ----------------------------------------------------------------------------
-- Annotations
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Annotation
(
    Id SERIAL NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_Annotation PRIMARY KEY (Id)
);



-- ----------------------------------------------------------------------------
-- Peptide Group
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.PeptideGroup
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Label CHAR(10) NOT NULL,
    Description TEXT,
    SequenceId INTEGER,
    Decoy BOOLEAN,
    Note VARCHAR(255),

    CONSTRAINT PK_PeptideGroup PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideGroup_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);
CREATE INDEX IX_PeptideGroup_RunId ON targetedms.PeptideGroup(RunId);

-- ALternative proteins
CREATE TABLE targetedms.Protein
(
    Id SERIAL NOT NULL,
    PeptideGroupId INT NOT NULL,
    LabkeySequenceId INT NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Description TEXT NULL ,

    CONSTRAINT PK_Protein PRIMARY KEY (Id),
    CONSTRAINT FK_Protein_PeptideGroup FOREIGN KEY (PeptideGroupId) REFERENCES targetedms.PeptideGroup(Id)
);
CREATE INDEX IX_Protein_PeptideGroupId ON targetedms.Protein(PeptideGroupId);

CREATE TABLE targetedms.PeptideGroupAnnotation
(
    AnnotationId INT NOT NULL,
    PeptideGroupId INT NOT NULL,

    CONSTRAINT PK_PeptideGroupAnnotation PRIMARY KEY (AnnotationId,PeptideGroupId),
    CONSTRAINT FK_PeptideGroupAnnotation_Annotation FOREIGN KEY (AnnotationId) REFERENCES targetedms.Annotation(Id),
    CONSTRAINT FK_PeptideGroupAnnotation_PeptideGroup FOREIGN KEY (PeptideGroupId) REFERENCES targetedms.PeptideGroup(Id)
);



-- ----------------------------------------------------------------------------
-- Peptide
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Peptide
(
    Id SERIAL NOT NULL,
    PeptideGroupId INT NOT NULL,
    Sequence VARCHAR(100) NOT NULL,
    StartIndex INT,
    EndIndex INT,
    PreviousAa CHAR(1),
    NextAa CHAR(1),
    CalcNeutralMass REAL NOT NULL,
    NumMissedCleavages INT NOT NULL,
    Rank INTEGER,
    RtCalculatorScore REAL,
    PredictedRetentionTime REAL,
    AvgMeasuredRetentionTime REAL,
    Decoy BOOLEAN,
    Note VARCHAR(255),

    CONSTRAINT PK_Peptide PRIMARY KEY (Id),
    CONSTRAINT FK_Peptide_PeptideGroup FOREIGN KEY (PeptideGroupId) REFERENCES targetedms.PeptideGroup(Id)
);
CREATE INDEX IX_Peptide_Sequence ON targetedms.Peptide (Sequence);
CREATE INDEX IX_Peptide_PeptideGroupId ON targetedms.Peptide(PeptideGroupId);

CREATE TABLE targetedms.PeptideAnnotation
(
    AnnotationId INT NOT NULL,
    PeptideId INT NOT NULL,

    CONSTRAINT PK_PeptideAnnotation PRIMARY KEY (AnnotationId,PeptideId),
    CONSTRAINT FK_PeptideAnnotation_Annotation FOREIGN KEY (AnnotationId) REFERENCES targetedms.Annotation(Id),
    CONSTRAINT FK_PeptideAnnotation_Peptide FOREIGN KEY (PeptideId) REFERENCES targetedms.Peptide(Id)
);

CREATE TABLE targetedms.PeptideChromInfo
(
    Id SERIAL NOT NULL,
    PeptideId INT  NOT NULL,
    SampleFileId INT NOT NULL,
    PeakCountRatio REAL NOT NULL,
    RetentionTime REAL,
    PredictedRetentionTime REAL,
    RatioToStandard REAL,

    CONSTRAINT PK_PeptideChromInfo PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideChromInfo_Peptide FOREIGN KEY (PeptideId) REFERENCES targetedms.Peptide(Id),
    CONSTRAINT FK_PeptideChromInfo_SampleFile FOREIGN KEY (SampleFileId) REFERENCES targetedms.SampleFile(Id)
);
CREATE INDEX IX_PeptideChromInfo_PeptideId ON targetedms.PeptideChromInfo(PeptideId);
CREATE INDEX IX_PeptideChromInfo_SampleFileId ON targetedms.PeptideChromInfo(SampleFileId);



-- ----------------------------------------------------------------------------
-- Precursor
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Precursor (
    Id SERIAL NOT NULL,
    PeptideId INT  NOT NULL,
    IsotopeLabelId INT,
    Mz REAL NOT NULL,
    Charge INT NOT NULL,
    NeutralMass REAL NOT NULL,
    ModifiedSequence VARCHAR(100) NOT NULL,
    CollisionEnergy REAL,
    DeclusteringPotential REAL,
    Decoy BOOLEAN,
    DecoyMassShift REAL,
    Note VARCHAR(255),

    CONSTRAINT PK_Precursor PRIMARY KEY (Id),
	CONSTRAINT FK_Precursor_Peptide FOREIGN KEY (PeptideId) REFERENCES targetedms.Peptide(Id)
);
CREATE INDEX IX_Precursor_PeptideId ON targetedms.Precursor(PeptideId);

CREATE TABLE targetedms.PrecursorAnnotation
(
    AnnotationId INT NOT NULL,
    PrecursorId INT NOT NULL,

    CONSTRAINT PK_PrecursorAnnotation PRIMARY KEY (AnnotationId,PrecursorId),
    CONSTRAINT FK_PrecursorAnnotation_Annotation FOREIGN KEY (AnnotationId) REFERENCES targetedms.Annotation(Id),
    CONSTRAINT FK_PrecursorAnnotation_Precursor FOREIGN KEY (PrecursorId) REFERENCES targetedms.Precursor(Id)
);

CREATE TABLE targetedms.PrecursorChromInfo
(
    Id SERIAL NOT NULL,
    PrecursorId INT  NOT NULL,
    SampleFileId INT NOT NULL,
    PeptideChromInfoId INT NOT NULL,
    BestRetentionTime REAL,
    MinStartTime REAL,
    MaxEndTime REAL,
    TotalArea REAL,
    TotalAreaNormalized REAL,
    TotalBackground REAL,
    MaxFwhm REAL,
    PeakCountRatio REAL,
    NumTruncated INT,
    Identified BOOLEAN,
    LibraryDtop REAL,
    OptimizationStep INT,
    UserSet BOOLEAN,
    NOTE VARCHAR(500),

    CONSTRAINT PK_PrecursorChromInfo PRIMARY KEY (Id),
    CONSTRAINT FK_PrecursorChromInfo_Precursor FOREIGN KEY (PrecursorId) REFERENCES targetedms.Precursor(Id),
    CONSTRAINT FK_PrecursorChromInfo_SampleFile FOREIGN KEY (SampleFileId) REFERENCES targetedms.SampleFile(Id),
    CONSTRAINT FK_PrecursorChromInfo_PeptideChromInfo FOREIGN KEY (PeptideChromInfoId) REFERENCES targetedms.PeptideChromInfo(Id)
);
CREATE INDEX IX_PrecursorChromInfo_PrecursorId ON targetedms.PrecursorChromInfo(PrecursorId);
CREATE INDEX IX_PrecursorChromInfo_SampleFileId ON targetedms.PrecursorChromInfo(SampleFileId);
CREATE INDEX IX_PrecursorChromInfo_PeptideChromInfoId ON targetedms.PrecursorChromInfo(PeptideChromInfoId);

CREATE TABLE targetedms.PrecursorChromInfoAnnotation
(
    AnnotationId INT NOT NULL,
    PrecursorChromInfoId INT NOT NULL,

    CONSTRAINT PK_PrecursorChromInfoAnnotation PRIMARY KEY (AnnotationId,PrecursorChromInfoId),
    CONSTRAINT FK_PrecursorChromInfoAnnotation_Annotation FOREIGN KEY (AnnotationId) REFERENCES targetedms.Annotation(Id),
    CONSTRAINT FK_PrecursorChromInfoAnnotation_Precursor FOREIGN KEY (PrecursorChromInfoId) REFERENCES targetedms.PrecursorChromInfo(Id)
);



-- ----------------------------------------------------------------------------
-- Transition
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Transition (
    Id SERIAL NOT NULL,
    PrecursorId INT NOT NULL,
    Mz REAL,
    Charge INT,
    NeutralMass REAL,
    NeutralLossMass REAL,
    FragmentType VARCHAR(10) NOT NULL,
    FragmentOrdinal INT,
    CleavageAa CHAR(1),
    LibraryRank INT,
    LibraryIntensity REAL,
    IsotopeDistIndex INT,
    IsotopeDistRank INT,
    IsotopeDistProportion REAL,
    Decoy BOOLEAN,
    DecoyMassShift REAL,
    Note VARCHAR(255),

    CONSTRAINT PK_Transition PRIMARY KEY (Id),
	CONSTRAINT FK_Transition_Precursor FOREIGN KEY (PrecursorId) REFERENCES targetedms.Precursor(Id)
);
CREATE INDEX IX_Transition_PrecursorId ON targetedms.Transition(PrecursorId);

CREATE TABLE targetedms.TransitionAnnotation
(
    AnnotationId INT NOT NULL,
    PrecursorId INT NOT NULL,

    CONSTRAINT PK_TransitionAnnotation PRIMARY KEY (AnnotationId,PrecursorId),
    CONSTRAINT FK_TransitionAnnotation_Annotation FOREIGN KEY (AnnotationId) REFERENCES targetedms.Annotation(Id),
    CONSTRAINT FK_TransitionAnnotation_Precursor FOREIGN KEY (PrecursorId) REFERENCES targetedms.Precursor(Id)
);

CREATE TABLE targetedms.TransitionChromInfo
(
    Id SERIAL NOT NULL,
    TransitionId INT  NOT NULL,
    SampleFileId INT NOT NULL,
    PrecursorChromInfoId INT NOT NULL,
    RetentionTime REAL,
    StartTime REAL,
    EndTime REAL,
    Height REAL,
    Area REAL,
    AreaNormalized REAL,
    Background REAL,
    Fwhm REAL,
    FwhmDegenerate BOOLEAN,
    Truncated BOOLEAN,
    PeakRank INT,
    Identified BOOLEAN,
    OptimizationStep INT,
    UserSet BOOLEAN,
    NOTE VARCHAR(500),

    CONSTRAINT PK_TransitionChromInfo PRIMARY KEY (Id),
    CONSTRAINT FK_TransitionChromInfo_Transition FOREIGN KEY (TransitionId) REFERENCES targetedms.Transition(Id),
    CONSTRAINT FK_TransitionChromInfo_SampleFile FOREIGN KEY (SampleFileId) REFERENCES targetedms.SampleFile(Id),
    CONSTRAINT FK_TransitionChromInfo_PrecursorChromInfo FOREIGN KEY (PrecursorChromInfoId) REFERENCES targetedms.PrecursorChromInfo(Id)
);
CREATE INDEX IX_TransitionChromInfo_TransitionId ON targetedms.TransitionChromInfo(TransitionId);
CREATE INDEX IX_TransitionChromInfo_SampleFileId ON targetedms.TransitionChromInfo(SampleFileId);
-- CREATE INDEX IX_TransitionChromInfo_PrecursorChromInfoId ON targetedms.TransitionChromInfo(PrecursorChromInfoId);

CREATE TABLE targetedms.TransitionChromInfoAnnotation
(
    AnnotationId INT NOT NULL,
    TransitionChromInfoId INT NOT NULL,

    CONSTRAINT PK_TransitionChromInfoAnnotation PRIMARY KEY (AnnotationId,TransitionChromInfoId),
    CONSTRAINT FK_TransitionChromInfoAnnotation_Annotation FOREIGN KEY (AnnotationId) REFERENCES targetedms.Annotation(Id),
    CONSTRAINT FK_TransitionChromInfoAnnotation_Transition FOREIGN KEY (TransitionChromInfoId) REFERENCES targetedms.TransitionChromInfo(Id)
);


-- ----------------------------------------------------------------------------
-- Chromatogram (from .skyd files)
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Chromatogram
(
    Id SERIAL,
    RunId Int NOT NULL,
    Chromatogram BYTEA NOT NULL,
    NumPoints INT NOT NULL,
    NumTransitions INT NOT NULL,

    CONSTRAINT PK_Chromatogram PRIMARY KEY (Id),
    CONSTRAINT FK_Chromatogram_RunId FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

/* targetedms-0.11-0.12.sql */

-- Create schema, tables, indexes, and constraints used for TargetedMS module here
-- All SQL VIEW definitions should be created in targetedms-create.sql and dropped in targetedms-drop.sql
ALTER TABLE targetedms.TransitionAnnotation DROP COLUMN PrecursorId;

ALTER TABLE targetedms.TransitionAnnotation ADD COLUMN TransitionId INT NOT NULL;
ALTER TABLE targetedms.TransitionAnnotation ADD CONSTRAINT FK_TransitionAnnotation_Transition FOREIGN KEY (TransitionId) REFERENCES targetedms.Transition(Id);

CREATE INDEX IDX_transitionannotation_transitionid ON targetedms.TransitionAnnotation(TransitionId);

/* targetedms-0.12-0.13.sql */

-- Store the bytes of the chromatograms on PrecursorChromInfo
ALTER TABLE targetedms.PrecursorChromInfo ADD COLUMN Chromatogram BYTEA;
ALTER TABLE targetedms.PrecursorChromInfo ADD COLUMN NumTransitions INT;
ALTER TABLE targetedms.PrecursorChromInfo ADD COLUMN NumPoints INT;

-- Remember which index within the chromatogram data we used for each TransitionChromInfo
ALTER TABLE targetedms.TransitionChromInfo ADD COLUMN chromatogramindex INT;

DROP TABLE targetedms.Chromatogram;

/* targetedms-0.13-0.14.sql */

-- ----------------------------------------------------------------------------
-- Enzyme
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.Enzyme
(
    Id SERIAL NOT NULL,
    Name VARCHAR(10) NOT NULL,
    Cut VARCHAR(10) NOT NULL,
    NoCut VARCHAR(10),
    Sense CHAR(1) NOT NULL,

    CONSTRAINT PK_Enzyme PRIMARY KEY (Id)
);

CREATE TABLE targetedms.RunEnzyme
(
    EnzymeId INT NOT NULL,
    RunId INT NOT NULL,
    MaxMissedCleavages INT,
    ExcludeRaggedEnds BOOLEAN,

    CONSTRAINT PK_RunEnzyme PRIMARY KEY (EnzymeId, RunId),
    CONSTRAINT FK_RunEnzyme_Enzyme FOREIGN KEY (EnzymeId) REFERENCES targetedms.Enzyme(Id),
    CONSTRAINT FK_RunEnzyme_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

-- ----------------------------------------------------------------------------
-- Modifications
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.ModificationSettings
(
    RunId INT NOT NULL,
    MaxVariableMods INT NOT NULL,
    MaxNeutralLosses INT NOT NULL,

    CONSTRAINT PK_ModificationSettings PRIMARY KEY (RunId),
    CONSTRAINT FK_ModificationSettings_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE TABLE targetedms.IsotopeLabel
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Standard BOOLEAN NOT NULL,

    CONSTRAINT PK_IsotopeLabel PRIMARY KEY (Id),
    CONSTRAINT FK_IsotopeLabel_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);
CREATE INDEX IX_IsotopeLabel_RunId ON targetedms.IsotopeLabel (RunId);

CREATE TABLE targetedms.StructuralModification
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    AminoAcid CHAR(1),
    Terminus CHAR(1),
    Formula VARCHAR(50) NOT NULL,
    MassDiffMono REAL,
    MassDiffAvg REAL,
    UnimodId INTEGER,

    CONSTRAINT PK_StructuralModification PRIMARY KEY (Id),
    CONSTRAINT FK_StructuralModification_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE TABLE targetedms.StructuralModLoss
(
    Id SERIAL NOT NULL,
    StructuralModId INT NOT NULL,
    Formula VARCHAR(50),
    MassDiffMono REAL,
    MassDiffAvg REAL,

    CONSTRAINT PK_StructuralModLoss PRIMARY KEY (Id),
    CONSTRAINT FK_StructuralModLoss_StructuralModification FOREIGN KEY (StructuralModId) REFERENCES targetedms.StructuralModification(Id)
);
CREATE INDEX IX_StructuralModification_StructuralModId ON targetedms.StructuralModLoss (StructuralModId);

CREATE TABLE targetedms.RunStructuralModification
(
    StructuralModId INT NOT NULL,
    RunId INT NOT NULL,
    ExplicitMod BOOLEAN,

    CONSTRAINT PK_RunStructuralModification PRIMARY KEY (StructuralModId),
    CONSTRAINT FK_RunStructuralModification_StructuralModification FOREIGN KEY (StructuralModId) REFERENCES targetedms.StructuralModification(Id),
    CONSTRAINT FK_RunStructuralModification_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);
CREATE INDEX IX_RunStructuralModification_RunId ON targetedms.RunStructuralModification (RunId);

CREATE TABLE targetedms.IsotopeModification
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    AminoAcid CHAR(1),
    Terminus CHAR(1),
    Formula VARCHAR(50) NOT NULL,
    MassDiffMono REAL,
    MassDiffAvg REAL,
    Label13C BOOLEAN,
    Label15N BOOLEAN,
    Label18O BOOLEAN,
    Label2H BOOLEAN,
    RelativeRt REAL,
    ExplicitMod BOOLEAN,
    UnimodId INTEGER,

    CONSTRAINT PK_IsotopeModification PRIMARY KEY (Id),
    CONSTRAINT FK_IsotopeModification_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);
CREATE INDEX IX_IsotopeModification_RunId ON targetedms.IsotopeModification (RunId);

CREATE TABLE targetedms.RunIsotopeModification
(
    IsotopeModId INT NOT NULL,
    RunId INT NOT NULL,
    IsotopeLabelId INT NOT NULL,
    ExplicitMod BOOLEAN,

    CONSTRAINT PK_RunIsotopeModification PRIMARY KEY (IsotopeModId),
    CONSTRAINT FK_RunIsotopeModification_IsotopeModification FOREIGN KEY (IsotopeModId) REFERENCES targetedms.IsotopeModification(Id),
    CONSTRAINT FK_RunIsotopeModification_Runs FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id),
    CONSTRAINT FK_RunIsotopeModification_IsotopeLabel FOREIGN KEY (IsotopeLabelId) REFERENCES targetedms.IsotopeLabel(Id)
);
CREATE INDEX IX_RunIsotopeModification_RunId ON targetedms.RunIsotopeModification (RunId);
CREATE INDEX IX_RunIsotopeModification_IsotopeLabelId ON targetedms.RunIsotopeModification (IsotopeLabelId);



-- ----------------------------------------------------------------------------
-- Peptide Modifications
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.PeptideStructuralModification
(
    Id SERIAL NOT NULL,
    PeptideId INT NOT NULL,
    StructuralModId INT NOT NULL,
    IndexAa INT NOT NULL,
    MassDiff REAL,

    CONSTRAINT PK_PeptideStructuralModification PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideStructuralModification_Peptide FOREIGN KEY (PeptideId) REFERENCES targetedms.Peptide(Id),
    CONSTRAINT FK_PeptideStructuralModification_StructuralModification FOREIGN KEY (StructuralModId) REFERENCES targetedms.StructuralModification(Id)
);
CREATE INDEX IX_PeptideStructuralModification_PeptideId ON targetedms.PeptideStructuralModification (PeptideId);
CREATE INDEX IX_PeptideStructuralModification_StructuralModId ON targetedms.PeptideStructuralModification (StructuralModId);

CREATE TABLE targetedms.PeptideIsotopeModification
(
    Id SERIAL NOT NULL,
    PeptideId INT NOT NULL,
    IsotopeModId INT NOT NULL,
    IndexAa INT NOT NULL,
    MassDiff REAL,

    CONSTRAINT PK_PeptideIsotopeModification PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideIsotopeModification_Peptide FOREIGN KEY (PeptideId) REFERENCES targetedms.Peptide(Id),
    CONSTRAINT FK_PeptideIsotopeModification_IsotopeModification FOREIGN KEY (IsotopeModId) REFERENCES targetedms.IsotopeModification(Id)
);
CREATE INDEX IX_PeptideIsotopeModification_PeptideId ON targetedms.PeptideIsotopeModification (PeptideId);
CREATE INDEX IX_PeptideIsotopeModification_IsotopeModId ON targetedms.PeptideIsotopeModification (IsotopeModId);



-- ----------------------------------------------------------------------------
-- Peak Area Ratios
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.TransitionAreaRatio
(
    Id SERIAL NOT NULL,
    TransitionChromInfoId INT NOT NULL,
    TransitionChromInfoStdId INT NOT NULL,
    IsotopeLabelId INT NOT NULL,
    IsotopeLabelStdId INT NOT NULL,
    AreaRatio REAL NOT NULL,

    CONSTRAINT PK_TransitionAreaRatio PRIMARY KEY (Id),
    CONSTRAINT FK_TransitionAreaRatio_TransitionChromInfoId FOREIGN KEY (TransitionChromInfoId) REFERENCES targetedms.TransitionChromInfo(Id),
    CONSTRAINT FK_TransitionAreaRatio_TransitionChromInfoStdId FOREIGN KEY (TransitionChromInfoStdId) REFERENCES targetedms.TransitionChromInfo(Id),
    CONSTRAINT FK_TransitionAreaRatio_IsotopeLabelId FOREIGN KEY (IsotopeLabelId) REFERENCES targetedms.IsotopeLabel(Id),
    CONSTRAINT FK_TransitionAreaRatio_IsotopeLabelStdId FOREIGN KEY (IsotopeLabelStdId) REFERENCES targetedms.IsotopeLabel(Id)
);
CREATE INDEX IX_TransitionAreaRatio_TransitionChromInfoId ON targetedms.TransitionAreaRatio (TransitionChromInfoId);
CREATE INDEX IX_TransitionAreaRatio_TransitionChromInfoStdId ON targetedms.TransitionAreaRatio (TransitionChromInfoStdId);
CREATE INDEX IX_TransitionAreaRatio_IsotopeLabelId ON targetedms.TransitionAreaRatio (IsotopeLabelId);
CREATE INDEX IX_TransitionAreaRatio_IsotopeLabelStdId ON targetedms.TransitionAreaRatio (IsotopeLabelStdId);

CREATE TABLE targetedms.PrecursorAreaRatio
(
    Id SERIAL NOT NULL,
    PrecursorChromInfoId INT NOT NULL,
    PrecursorChromInfoStdId INT NOT NULL,
    IsotopeLabelId INT NOT NULL,
    IsotopeLabelStdId INT NOT NULL,
    AreaRatio REAL NOT NULL,

    CONSTRAINT PK_PrecursorAreaRatio PRIMARY KEY (Id),
    CONSTRAINT FK_PrecursorAreaRatio_PrecursorChromInfoId FOREIGN KEY (PrecursorChromInfoId) REFERENCES targetedms.PrecursorChromInfo(Id),
    CONSTRAINT FK_PrecursorAreaRatio_PrecursorChromInfoStdId FOREIGN KEY (PrecursorChromInfoStdId) REFERENCES targetedms.PrecursorChromInfo(Id),
    CONSTRAINT FK_PrecursorAreaRatio_IsotopeLabelId FOREIGN KEY (IsotopeLabelId) REFERENCES targetedms.IsotopeLabel(Id),
    CONSTRAINT FK_PrecursorAreaRatio_IsotopeLabelStdId FOREIGN KEY (IsotopeLabelStdId) REFERENCES targetedms.IsotopeLabel(Id)
);
CREATE INDEX IX_PrecursorAreaRatio_PrecursorChromInfoId ON targetedms.PrecursorAreaRatio (PrecursorChromInfoId);
CREATE INDEX IX_PrecursorAreaRatio_PrecursorChromInfoStdId ON targetedms.PrecursorAreaRatio (PrecursorChromInfoStdId);
CREATE INDEX IX_PrecursorAreaRatio_IsotopeLabelId ON targetedms.PrecursorAreaRatio (IsotopeLabelId);
CREATE INDEX IX_PrecursorAreaRatio_IsotopeLabelStdId ON targetedms.PrecursorAreaRatio (IsotopeLabelStdId);

CREATE TABLE targetedms.PeptideAreaRatio
(
    Id SERIAL NOT NULL,
    PeptideChromInfoId INT NOT NULL,
    PeptideChromInfoStdId INT NOT NULL,
    IsotopeLabelId INT NOT NULL,
    IsotopeLabelStdId INT NOT NULL,
    AreaRatio REAL NOT NULL,

    CONSTRAINT PK_PeptideAreaRatio PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideAreaRatio_PeptideChromInfoId FOREIGN KEY (PeptideChromInfoId) REFERENCES targetedms.PeptideChromInfo(Id),
    CONSTRAINT FK_PeptideAreaRatio_PeptideChromInfoStdId FOREIGN KEY (PeptideChromInfoStdId) REFERENCES targetedms.PeptideChromInfo(Id),
    CONSTRAINT FK_PeptideAreaRatio_IsotopeLabelId FOREIGN KEY (IsotopeLabelId) REFERENCES targetedms.IsotopeLabel(Id),
    CONSTRAINT FK_PeptideAreaRatio_IsotopeLabelStdId FOREIGN KEY (IsotopeLabelStdId) REFERENCES targetedms.IsotopeLabel(Id)
);
CREATE INDEX IX_PeptideAreaRatio_PeptideChromInfoId ON targetedms.PeptideAreaRatio (PeptideChromInfoId);
CREATE INDEX IX_PeptideAreaRatio_PeptideChromInfoStdId ON targetedms.PeptideAreaRatio (PeptideChromInfoStdId);
CREATE INDEX IX_PeptideAreaRatio_IsotopeLabelId ON targetedms.PeptideAreaRatio (IsotopeLabelId);
CREATE INDEX IX_PeptideAreaRatio_IsotopeLabelStdId ON targetedms.PeptideAreaRatio (IsotopeLabelStdId);



-- ----------------------------------------------------------------------------
-- Spectrum Libraries
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.LibrarySource
(
    Id SERIAL NOT NULL,
    Type VARCHAR(10) NOT NULL,  -- One of NIST, GPM or Bibliospec
    Score1Name VARCHAR(20),
    Score2Name VARCHAR(20),
    Score3Name VARCHAR(20),

    CONSTRAINT PK_LibrarySource PRIMARY KEY (Id)
);

CREATE TABLE targetedms.LibrarySettings
(
    RunId INT NOT NULL,
    Pick VARCHAR(10),
    RankType VARCHAR(20),
    PeptideCount INT,

    CONSTRAINT PK_LibrarySettings PRIMARY KEY (RunId),
    CONSTRAINT FK_LibrarySettings_RunId FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id)
);

CREATE TABLE targetedms.SpectrumLibrary
(
    Id SERIAL NOT NULL,
    RunId INT NOT NULL,
    LibrarySourceId INT NOT NULL,
    LibraryType VARCHAR(20) NOT NULL, -- One of 'bibliospec', 'bibliospec_lite', 'xhunter', 'nist', 'spectrast'.
    Name VARCHAR(10) NOT NULL,
    FileNameHint VARCHAR(100),
    LibraryId VARCHAR(50) NOT NULL,
    Revision VARCHAR(10),

    CONSTRAINT PK_SpectrumLibrary PRIMARY KEY (Id),
    CONSTRAINT FK_SpectrumLibrary_RunId FOREIGN KEY (RunId) REFERENCES targetedms.Runs(Id),
    CONSTRAINT FK_SpectrumLibrary_LibrarySourceId FOREIGN KEY (LibrarySourceId) REFERENCES targetedms.LibrarySource(Id)
);
CREATE INDEX IX_SpectrumLibrary_RunId ON targetedms.SpectrumLibrary (RunId);
CREATE INDEX IX_SpectrumLibrary_LibrarySourceId ON targetedms.SpectrumLibrary (LibrarySourceId);



-- ----------------------------------------------------------------------------
-- Transition related tables
-- ----------------------------------------------------------------------------
CREATE TABLE targetedms.TransitionOptimization
(
     Id SERIAL NOT NULL,
     TransitionId INT NOT NULL,
     OptimizationType VARCHAR(10) NOT NULL,
     OptValue REAL NOT NULL,

     CONSTRAINT PK_TransitionOptimization PRIMARY KEY (Id),
     CONSTRAINT FK_TransitionOptimization_TransitionId FOREIGN KEY (TransitionId) REFERENCES targetedms.Transition(Id)
);
CREATE INDEX IX_TransitionOptimization_TransitionId ON targetedms.TransitionOptimization (TransitionId);

CREATE TABLE targetedms.TransitionLoss
(
    Id SERIAL NOT NULL,
    TransitionId INT NOT NULL,
    StructuralModLossId INT NOT NULL,

    CONSTRAINT PK_TransitionLoss PRIMARY KEY (Id),
    CONSTRAINT FK_TransitionLoss_TransitionId FOREIGN KEY (TransitionId) REFERENCES targetedms.Transition(Id),
    CONSTRAINT FK_TransitionLoss_StructuralModLossId FOREIGN KEY (StructuralModLossId) REFERENCES targetedms.StructuralModLoss(Id)
);
CREATE INDEX IX_TransitionLoss_TransitionId ON targetedms.TransitionLoss (TransitionId);
CREATE INDEX IX_TransitionLoss_StructuralModLossId ON targetedms.TransitionLoss (StructuralModLossId);

/* targetedms-0.14-0.15.sql */

-- Move the RelativeRt column from IsotopeModification to RunIsotopeModification
ALTER TABLE targetedms.RunIsotopeModification ADD COLUMN RelativeRt VARCHAR(20);
ALTER TABLE targetedms.IsotopeModification DROP COLUMN RelativeRt;

/* targetedms-0.15-0.16.sql */

-- Remove RunId columns from StructuralModification and IsotopeModification tables.
-- Modifications are not specific to a single Skyline document, they may be used
-- by multiple documents.
ALTER TABLE targetedms.IsotopeModification DROP COLUMN RunId;
ALTER TABLE targetedms.StructuralModification DROP COLUMN RunId;

-- 'Formula' can be NULL
ALTER TABLE targetedms.IsotopeModification ALTER COLUMN Formula DROP NOT NULL;
ALTER TABLE targetedms.StructuralModification ALTER COLUMN Formula DROP NOT NULL;

-- Add IsotopeLabelId FK
ALTER TABLE targetedms.Precursor ADD CONSTRAINT FK_Precursor_IsotopeLabel FOREIGN KEY (IsotopeLabelId) REFERENCES targetedms.IsotopeLabel(Id);

/* targetedms-0.16-0.17.sql */

ALTER TABLE targetedms.PeptideGroup ALTER COLUMN Label TYPE VARCHAR(50);

/* targetedms-0.17-0.18.sql */

ALTER TABLE targetedms.SpectrumLibrary ALTER COLUMN LibraryId TYPE VARCHAR(200);
ALTER TABLE targetedms.SpectrumLibrary RENAME COLUMN LibraryId TO SkylineLibraryId;

INSERT INTO targetedms.LibrarySource (type, score1name) VALUES ('BiblioSpec', 'count_measured');
INSERT INTO targetedms.LibrarySource (type, score1name, score2name) VALUES ('GPM', 'expect', 'processed_intensity');
INSERT INTO targetedms.LibrarySource (type, score1name, score2name, score3name) VALUES ('NIST', 'expect', 'total_intensity', 'tfratio');

CREATE TABLE targetedms.PrecursorLibInfo
(
    Id SERIAL NOT NULL,
    PrecursorId INT NOT NULL,
    SpectrumLibraryId INT NOT NULL,
    Score1 REAL,
    Score2 REAL,
    Score3 REAL,

    CONSTRAINT PK_PrecursorLibInfo PRIMARY KEY (Id),
    CONSTRAINT FK_PrecursorLibInfo_Precursor FOREIGN KEY (PrecursorId) REFERENCES targetedms.Precursor(Id),
    CONSTRAINT FK_PrecursorLibInfo_SpectrumLibrary FOREIGN KEY (SpectrumLibraryId) REFERENCES targetedms.SpectrumLibrary(Id)
);
CREATE INDEX IX_PrecursorLibInfo_PrecursorId ON targetedms.PrecursorLibInfo(PrecursorId);
CREATE INDEX IX_PrecursorLibInfo_SpectrumLibraryId ON targetedms.PrecursorLibInfo(SpectrumLibraryId);

/* targetedms-0.18-0.19.sql */

ALTER TABLE targetedms.SpectrumLibrary ALTER COLUMN Name TYPE VARCHAR(200);

/* targetedms-0.20-0.21.sql */

-- Don't use a central annotation table - just add the names/values directly on the specific types of annotations
DROP TABLE targetedms.PeptideGroupAnnotation;
DROP TABLE targetedms.PrecursorAnnotation;
DROP TABLE targetedms.PrecursorChromInfoAnnotation;
DROP TABLE targetedms.TransitionAnnotation;
DROP TABLE targetedms.TransitionChromInfoAnnotation;
DROP TABLE targetedms.PeptideAnnotation;
DROP TABLE targetedms.Annotation;

CREATE TABLE targetedms.PeptideGroupAnnotation
(
    Id SERIAL NOT NULL,
    PeptideGroupId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_PeptideGroupAnnotation PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideGroupAnnotation_PeptideGroup FOREIGN KEY (PeptideGroupId) REFERENCES targetedms.PeptideGroup(Id),
    CONSTRAINT UQ_PeptideGroupAnnotation_Name_PeptideGroup UNIQUE (Name, PeptideGroupId)
);

CREATE TABLE targetedms.PrecursorAnnotation
(
    Id SERIAL NOT NULL,
    PrecursorId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_PrecursorAnnotation PRIMARY KEY (Id),
    CONSTRAINT FK_PrecursorAnnotation_Precursor FOREIGN KEY (PrecursorId) REFERENCES targetedms.Precursor(Id),
    CONSTRAINT UQ_PrecursorAnnotation_Name_Precursor UNIQUE (Name, PrecursorId)
);

CREATE TABLE targetedms.PrecursorChromInfoAnnotation
(
    Id SERIAL NOT NULL,
    PrecursorChromInfoId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_PrecursorChromInfoAnnotation PRIMARY KEY (Id),
    CONSTRAINT FK_PrecursorChromInfoAnnotation_PrecursorChromInfo FOREIGN KEY (PrecursorChromInfoId) REFERENCES targetedms.PrecursorChromInfo(Id),
    CONSTRAINT UQ_PrecursorChromInfoAnnotation_Name_PrecursorChromInfo UNIQUE (Name, PrecursorChromInfoId)
);

CREATE TABLE targetedms.TransitionAnnotation
(
    Id SERIAL NOT NULL,
    TransitionId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_TransitionAnnotation PRIMARY KEY (Id),
    CONSTRAINT FK_TransitionAnnotation_Transition FOREIGN KEY (TransitionId) REFERENCES targetedms.Transition(Id),
    CONSTRAINT UQ_TransitionAnnotation_Name_Transition UNIQUE (Name, TransitionId)
);

CREATE TABLE targetedms.TransitionChromInfoAnnotation
(
    Id SERIAL NOT NULL,
    TransitionChromInfoId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_TransitionChromInfoAnnotation PRIMARY KEY (Id),
    CONSTRAINT FK_TransitionChromInfoAnnotation_TransitionChromInfo FOREIGN KEY (TransitionChromInfoId) REFERENCES targetedms.TransitionChromInfo(Id),
    CONSTRAINT UQ_TransitionChromInfoAnnotation_Name_TransitionChromInfo UNIQUE (Name, TransitionChromInfoId)
);

CREATE TABLE targetedms.PeptideAnnotation
(
    Id SERIAL NOT NULL,
    PeptideId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Value VARCHAR(255) NOT NULL,

    CONSTRAINT PK_PeptideAnnotation PRIMARY KEY (Id),
    CONSTRAINT FK_PeptideAnnotation_Peptide FOREIGN KEY (PeptideId) REFERENCES targetedms.Peptide(Id),
    CONSTRAINT UQ_PeptideAnnotation_Name_Peptide UNIQUE (Name, PeptideId)
);


ALTER TABLE targetedms.SampleFile ALTER COLUMN SkylineId DROP NOT NULL;

ALTER TABLE targetedms.Precursor ALTER COLUMN ModifiedSequence DROP NOT NULL;

/* targetedms-0.21-0.22.sql */

ALTER TABLE targetedms.Predictor DROP COLUMN Charge;
ALTER TABLE targetedms.Predictor DROP COLUMN Slope;
ALTER TABLE targetedms.Predictor DROP COLUMN Intercept;

CREATE TABLE targetedms.PredictorSettings
(
    Id SERIAL NOT NULL,
    PredictorId INT NOT NULL,
    Charge INT,
    Slope REAL,
    Intercept REAL,

    CONSTRAINT PK_PredictorSettings PRIMARY KEY (Id),
    CONSTRAINT UQ_PredictorSettings UNIQUE (PredictorId, Charge),
    CONSTRAINT FK_PredictorSettings_PredictorId FOREIGN KEY (PredictorId) REFERENCES targetedms.Predictor(Id)
);

ALTER TABLE targetedms.transitionpredictionsettings ALTER COLUMN precursormasstype TYPE VARCHAR(20);
ALTER TABLE targetedms.transitionpredictionsettings ALTER COLUMN productmasstype TYPE VARCHAR(20);

/* targetedms-0.22-0.23.sql */

-- A structural modification can be attached to multiple amino acids, which are stored comma-separated
ALTER TABLE targetedms.structuralmodification ALTER COLUMN aminoacid TYPE VARCHAR(30);

ALTER TABLE targetedms.runstructuralmodification DROP CONSTRAINT pk_runstructuralmodification;

ALTER TABLE targetedms.runstructuralmodification ADD CONSTRAINT pk_runstructuralmodification PRIMARY KEY (structuralmodid, runid);