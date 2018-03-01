/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

CREATE TABLE mpower.DiagnosisStatus
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(64) NOT NULL,

    CONSTRAINT PK_DiagnosisStatus PRIMARY KEY (Id)
);
INSERT INTO mpower.DiagnosisStatus VALUES (1, 'Yes, within the past year');
INSERT INTO mpower.DiagnosisStatus VALUES (2, 'Yes, more than a year ago');
INSERT INTO mpower.DiagnosisStatus VALUES (3, 'No');

CREATE TABLE mpower.HispanicOrigin
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(64) NOT NULL,

    CONSTRAINT PK_HispanicOrigin PRIMARY KEY (Id)
);
INSERT INTO mpower.HispanicOrigin VALUES (1, 'Mexican, Mexican-American, or Chicano');
INSERT INTO mpower.HispanicOrigin VALUES (2, 'Puerto Rican');
INSERT INTO mpower.HispanicOrigin VALUES (3, 'Cuban or Cuban-American');
INSERT INTO mpower.HispanicOrigin VALUES (4, 'Other');

CREATE TABLE mpower.EducationLevel
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(64) NOT NULL,

    CONSTRAINT PK_EducationLevel PRIMARY KEY (Id)
);
INSERT INTO mpower.EducationLevel VALUES (1, 'Some high school');
INSERT INTO mpower.EducationLevel VALUES (2, 'High school graduate');
INSERT INTO mpower.EducationLevel VALUES (3, 'Some college');
INSERT INTO mpower.EducationLevel VALUES (4, 'Trade/technical/vocational training');
INSERT INTO mpower.EducationLevel VALUES (5, 'College graduate');
INSERT INTO mpower.EducationLevel VALUES (6, 'Some postgraduate work');
INSERT INTO mpower.EducationLevel VALUES (7, 'Post graduate degree');

CREATE TABLE mpower.MaritalStatus
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(64) NOT NULL,

    CONSTRAINT PK_MaritalStatus PRIMARY KEY (Id)
);
INSERT INTO mpower.MaritalStatus VALUES (1, 'Single (never married or partnered)');
INSERT INTO mpower.MaritalStatus VALUES (2, 'Married or partnered');
INSERT INTO mpower.MaritalStatus VALUES (3, 'Divorced');
INSERT INTO mpower.MaritalStatus VALUES (4, 'Widowed');
INSERT INTO mpower.MaritalStatus VALUES (5, 'Separated');

CREATE TABLE mpower.EmploymentStatus
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(64) NOT NULL,

    CONSTRAINT PK_EmploymentStatus PRIMARY KEY (Id)
);
INSERT INTO mpower.EmploymentStatus VALUES (1, 'Working full-time');
INSERT INTO mpower.EmploymentStatus VALUES (2, 'Working part-time');
INSERT INTO mpower.EmploymentStatus VALUES (3, 'Retired');
INSERT INTO mpower.EmploymentStatus VALUES (4, 'Unemployed');
INSERT INTO mpower.EmploymentStatus VALUES (5, 'Other');

CREATE TABLE mpower.PatientDemographics
(
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    DiagnosisStatus INTEGER,
    BirthDate DATE,

    RaceWhite BIT NOT NULL DEFAULT 0,
    RaceBlack BIT NOT NULL DEFAULT 0,
    RaceNativeAmerican BIT NOT NULL DEFAULT 0,
    RaceAsian BIT NOT NULL DEFAULT 0,
    RaceHawaiian BIT NOT NULL DEFAULT 0,
    RaceOther BIT NOT NULL DEFAULT 0,
    RaceHispanic BIT NOT NULL DEFAULT 0,
    HispanicOrigin INTEGER,
    HispanicOriginOther NVARCHAR(64),

    ZipCode INTEGER,
    EducationLevel INTEGER,
    MaritalStatus INTEGER,
    EmploymentStatus INTEGER,
    EmploymentStatusOther NVARCHAR(64),

    CONSTRAINT PK_PatientDemographics PRIMARY KEY (PatientId),
    CONSTRAINT FK_DiagnosisStatus_DiagnosisStatus FOREIGN KEY (DiagnosisStatus) REFERENCES mpower.DiagnosisStatus(Id),
    CONSTRAINT FK_HispanicOrigin_HispanicOrigin FOREIGN KEY (HispanicOrigin) REFERENCES mpower.HispanicOrigin(Id),
    CONSTRAINT FK_EducationLevel_EducationLevel FOREIGN KEY (EducationLevel) REFERENCES mpower.EducationLevel(Id),
    CONSTRAINT FK_MaritalStatus_MaritalStatus FOREIGN KEY (MaritalStatus) REFERENCES mpower.MaritalStatus(Id),
    CONSTRAINT FK_EmploymentStatus_EmploymentStatus FOREIGN KEY (EmploymentStatus) REFERENCES mpower.EmploymentStatus(Id)
);

CREATE TABLE mpower.Insurance
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    Name NVARCHAR(256) NOT NULL ,
    Commercial BIT NOT NULL DEFAULT 0,
    Military BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_Insurance PRIMARY KEY (RowId),
    CONSTRAINT FK_Insurance_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics(PatientId)
);

CREATE TABLE mpower.PSALevel
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(64) NOT NULL,

    CONSTRAINT PK_PSALevel PRIMARY KEY (Id)
);
INSERT INTO mpower.PSALevel VALUES (1, '0-4 ng/mL');
INSERT INTO mpower.PSALevel VALUES (2, '4-10 ng/mL');
INSERT INTO mpower.PSALevel VALUES (3, '10-20 ng/mL');
INSERT INTO mpower.PSALevel VALUES (4, '>20 ng/mL');
INSERT INTO mpower.PSALevel VALUES (5, 'Don''t know or not sure');

CREATE TABLE mpower.CancerExtent
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_CancerExtent PRIMARY KEY (Id)
);
INSERT INTO mpower.CancerExtent VALUES (1, 'Cancer is found in the prostate only');
INSERT INTO mpower.CancerExtent VALUES (2, 'Cancer has spread outside of the prostate to local area (lymph nodes)');
INSERT INTO mpower.CancerExtent VALUES (3, 'Cancer has spread outside of the prostate to distant areas, such as bones');

CREATE TABLE mpower.YesNoOther
(
    Id INTEGER NOT NULL,
    Name VARCHAR(256) NOT NULL,

    CONSTRAINT PK_YesNoOther PRIMARY KEY (Id)
);
INSERT INTO mpower.YesNoOther VALUES (0, 'Yes');
INSERT INTO mpower.YesNoOther VALUES (1, 'No');
INSERT INTO mpower.YesNoOther VALUES (2, 'Not sure');

CREATE TABLE mpower.ClinicalDiagnosis
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    DiagnosisDate DATE,
    PSALevel INTEGER,
    CancerExtent INTEGER,
    GeneticTest INTEGER,

    CONSTRAINT PK_ClinicalDiagnosis PRIMARY KEY (RowId),
    CONSTRAINT FK_ClinicalDiagnosis_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics(PatientId),
    CONSTRAINT FK_PSALevel_PSALevel FOREIGN KEY (PSALevel) REFERENCES mpower.PSALevel(Id),
    CONSTRAINT FK_CancerExtent_CancerExtent FOREIGN KEY (CancerExtent) REFERENCES mpower.CancerExtent(Id),
    CONSTRAINT FK_GeneticTest_YesNoOther FOREIGN KEY (GeneticTest) REFERENCES mpower.YesNoOther(Id)
);

CREATE TABLE mpower.FamilyRelationship
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_FamilyRelationship PRIMARY KEY (Id)
);
INSERT INTO mpower.FamilyRelationship VALUES (1, 'Brother (full, half)');
INSERT INTO mpower.FamilyRelationship VALUES (2, 'Sister (full, half)');
INSERT INTO mpower.FamilyRelationship VALUES (3, 'Children');
INSERT INTO mpower.FamilyRelationship VALUES (4, 'Mother');
INSERT INTO mpower.FamilyRelationship VALUES (5, 'Mother''s father');
INSERT INTO mpower.FamilyRelationship VALUES (6, 'Mother''s brother');
INSERT INTO mpower.FamilyRelationship VALUES (7, 'Cousins on mother''s side');
INSERT INTO mpower.FamilyRelationship VALUES (8, 'Father');
INSERT INTO mpower.FamilyRelationship VALUES (9, 'Father''s father');
INSERT INTO mpower.FamilyRelationship VALUES (10, 'Father''s brother');
INSERT INTO mpower.FamilyRelationship VALUES (11, 'Cousins on father''s side');
INSERT INTO mpower.FamilyRelationship VALUES (12, 'Additional family member');

CREATE TABLE mpower.AgeAtDiagnosis
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_AgeAtDiagnosis PRIMARY KEY (Id)
);
INSERT INTO mpower.AgeAtDiagnosis VALUES (1, '18 and under');
INSERT INTO mpower.AgeAtDiagnosis VALUES (2, '18-40');
INSERT INTO mpower.AgeAtDiagnosis VALUES (3, '40-60');
INSERT INTO mpower.AgeAtDiagnosis VALUES (4, '60+');
INSERT INTO mpower.AgeAtDiagnosis VALUES (5, 'Don''t know');

CREATE TABLE mpower.CancerStartLocation
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_CancerStartLocation PRIMARY KEY (Id)
);
INSERT INTO mpower.CancerStartLocation VALUES (1, 'Bladder');
INSERT INTO mpower.CancerStartLocation VALUES (2, 'Brain');
INSERT INTO mpower.CancerStartLocation VALUES (3, 'Breast');
INSERT INTO mpower.CancerStartLocation VALUES (4, 'Cervical');
INSERT INTO mpower.CancerStartLocation VALUES (5, 'Childhood');
INSERT INTO mpower.CancerStartLocation VALUES (6, 'Colorectal');
INSERT INTO mpower.CancerStartLocation VALUES (7, 'Endocrine');
INSERT INTO mpower.CancerStartLocation VALUES (8, 'Esophageal');
INSERT INTO mpower.CancerStartLocation VALUES (9, 'Head and Neck');
INSERT INTO mpower.CancerStartLocation VALUES (10, 'Kidney');
INSERT INTO mpower.CancerStartLocation VALUES (11, 'Leukemia');
INSERT INTO mpower.CancerStartLocation VALUES (12, 'Lung');
INSERT INTO mpower.CancerStartLocation VALUES (13, 'Lymphoma');
INSERT INTO mpower.CancerStartLocation VALUES (14, 'Melanoma');
INSERT INTO mpower.CancerStartLocation VALUES (15, 'Ovarian');
INSERT INTO mpower.CancerStartLocation VALUES (16, 'Pancreatic');
INSERT INTO mpower.CancerStartLocation VALUES (17, 'Sarcoma-soft tissue or bone');
INSERT INTO mpower.CancerStartLocation VALUES (18, 'Stomach');
INSERT INTO mpower.CancerStartLocation VALUES (19, 'Testicular');
INSERT INTO mpower.CancerStartLocation VALUES (20, 'Thyroid');
INSERT INTO mpower.CancerStartLocation VALUES (21, 'Don''t know');

CREATE TABLE mpower.FamilyHistory
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    Relationship INTEGER,
    AgeAtDiagnosis INTEGER,
    CancerStartLocation INTEGER,
    OtherRelationship NVARCHAR(256),

    CONSTRAINT PK_FamilyHistory PRIMARY KEY (RowId),
    CONSTRAINT FK_FamilyHistory_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics(PatientId),
    CONSTRAINT FK_Relationship_FamilyRelationship FOREIGN KEY (Relationship) REFERENCES mpower.FamilyRelationship(Id),
    CONSTRAINT FK_AgeAtDiagnosis_AgeAtDiagnosis FOREIGN KEY (AgeAtDiagnosis) REFERENCES mpower.AgeAtDiagnosis(Id),
    CONSTRAINT FK_CancerStartLocation_CancerStartLocation FOREIGN KEY (CancerStartLocation) REFERENCES mpower.CancerStartLocation(Id)
);

CREATE TABLE mpower.CurrentTreatmentState
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_CurrentTreatmentState PRIMARY KEY (Id)
);
INSERT INTO mpower.CurrentTreatmentState VALUES (1, 'I have not made a decision about treatment yet');
INSERT INTO mpower.CurrentTreatmentState VALUES (2, 'I am on active surveillance or watchful waiting');
INSERT INTO mpower.CurrentTreatmentState VALUES (3, 'I had treatment (such as surgery or radiation) for my prostate cancer and my cancer has not come back');
INSERT INTO mpower.CurrentTreatmentState VALUES (4, 'I had treatment for my prostate cancer and I am being treated because my PSA was rising');
INSERT INTO mpower.CurrentTreatmentState VALUES (5, 'My prostate cancer spread outside of the prostate to other parts of my body, which is metastatic prostate cancer');

CREATE TABLE mpower.PrimaryClinician
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_PrimaryClinician PRIMARY KEY (Id)
);
INSERT INTO mpower.PrimaryClinician VALUES (1, 'Doctor (Medical Oncologist)');
INSERT INTO mpower.PrimaryClinician VALUES (2, 'Doctor (Urologist)');
INSERT INTO mpower.PrimaryClinician VALUES (3, 'Doctor (Surgeon)');
INSERT INTO mpower.PrimaryClinician VALUES (4, 'Doctor (Primary Care)');
INSERT INTO mpower.PrimaryClinician VALUES (5, 'Doctor (Radiation Oncologist)');
INSERT INTO mpower.PrimaryClinician VALUES (6, 'Nurse or other health professional');

CREATE TABLE mpower.TreatmentSatisfaction
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_TreatmentSatisfaction PRIMARY KEY (Id)
);
INSERT INTO mpower.TreatmentSatisfaction VALUES (1, 'Extremely dissatisfied');
INSERT INTO mpower.TreatmentSatisfaction VALUES (2, 'Dissatisfied');
INSERT INTO mpower.TreatmentSatisfaction VALUES (3, 'Uncertain');
INSERT INTO mpower.TreatmentSatisfaction VALUES (4, 'Satisfied');
INSERT INTO mpower.TreatmentSatisfaction VALUES (5, 'Extremely satisfied');

CREATE TABLE mpower.Treatment
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    CurrentTreatmentState INTEGER,
    TreatmentWithinYear BIT NOT NULL DEFAULT 0,
    PrimaryClinician INTEGER,
    CancerSpreadBeyondProstate BIT NOT NULL DEFAULT 0,
    SpreadToLymphs BIT NOT NULL DEFAULT 0,
    SpreadToBones BIT NOT NULL DEFAULT 0,
    SpreadToOrgans BIT NOT NULL DEFAULT 0,
    OrgansSpreadTo NVARCHAR(500),
    SpreadToDontKnow BIT NOT NULL DEFAULT 0,
    TreatmentSatisfaction INTEGER,

    CONSTRAINT PK_Treatment PRIMARY KEY (RowId),
    CONSTRAINT FK_Treatment_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics(PatientId),
    CONSTRAINT FK_CurrentTreatmentState_CurrentTreatmentState FOREIGN KEY (CurrentTreatmentState) REFERENCES mpower.CurrentTreatmentState(Id),
    CONSTRAINT FK_PrimaryClinician_PrimaryClinician FOREIGN KEY (PrimaryClinician) REFERENCES mpower.PrimaryClinician(Id),
    CONSTRAINT FK_TreatmentSatisfaction_TreatmentSatisfaction FOREIGN KEY (TreatmentSatisfaction) REFERENCES mpower.TreatmentSatisfaction(Id)
);

CREATE TABLE mpower.TreatmentType
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    Name NVARCHAR(256),
    StartDate DATE,
    EndDate DATE,
    Surgery BIT NOT NULL DEFAULT 0,
    Radiation BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_TreatmentType PRIMARY KEY (RowId),
    CONSTRAINT FK_TreatmentType_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics(PatientId)
);

CREATE TABLE mpower.ProblemScale
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_ProblemScale PRIMARY KEY (Id)
);
INSERT INTO mpower.ProblemScale VALUES (1, 'No problem');
INSERT INTO mpower.ProblemScale VALUES (2, 'Very small problem');
INSERT INTO mpower.ProblemScale VALUES (3, 'Small problem');
INSERT INTO mpower.ProblemScale VALUES (4, 'Moderate problem');
INSERT INTO mpower.ProblemScale VALUES (5, 'Big problem');

CREATE TABLE mpower.StandardScale
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_StandardScale PRIMARY KEY (Id)
);
INSERT INTO mpower.StandardScale VALUES (1, 'Very poor to none');
INSERT INTO mpower.StandardScale VALUES (2, 'Poor');
INSERT INTO mpower.StandardScale VALUES (3, 'Fair');
INSERT INTO mpower.StandardScale VALUES (4, 'Good');
INSERT INTO mpower.StandardScale VALUES (5, 'Very good');

CREATE TABLE mpower.UrineLeak
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_UrineLeak PRIMARY KEY (Id)
);
INSERT INTO mpower.UrineLeak VALUES (1, 'More than once a day');
INSERT INTO mpower.UrineLeak VALUES (2, 'About once a day');
INSERT INTO mpower.UrineLeak VALUES (3, 'More than once a week');
INSERT INTO mpower.UrineLeak VALUES (4, 'About once a week');
INSERT INTO mpower.UrineLeak VALUES (5, 'Rarely or never');

CREATE TABLE mpower.UrineControl
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_UrineControl PRIMARY KEY (Id)
);
INSERT INTO mpower.UrineControl VALUES (1, 'No urinary control whatsoever');
INSERT INTO mpower.UrineControl VALUES (2, 'Frequent dribbling');
INSERT INTO mpower.UrineControl VALUES (3, 'Occasional dribbling');
INSERT INTO mpower.UrineControl VALUES (4, 'Total control');

CREATE TABLE mpower.DiaperUse
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_DiaperUse PRIMARY KEY (Id)
);
INSERT INTO mpower.DiaperUse VALUES (1, 'None');
INSERT INTO mpower.DiaperUse VALUES (2, '1 pad per day');
INSERT INTO mpower.DiaperUse VALUES (3, '2 pads per day');
INSERT INTO mpower.DiaperUse VALUES (4, '3 or more pads per day');

CREATE TABLE mpower.ErectionQuality
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_ErectionQuality PRIMARY KEY (Id)
);
INSERT INTO mpower.ErectionQuality VALUES (1, 'None at all');
INSERT INTO mpower.ErectionQuality VALUES (2, 'Not firm enough for any sexual activity');
INSERT INTO mpower.ErectionQuality VALUES (3, 'Firm enough for masturbation and foreplay only');
INSERT INTO mpower.ErectionQuality VALUES (4, 'Firm enough for intercouse');

CREATE TABLE mpower.ErectionFrequency
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_ErectionFrequency PRIMARY KEY (Id)
);
INSERT INTO mpower.ErectionFrequency VALUES (1, 'I NEVER had an erection when I wanted one');
INSERT INTO mpower.ErectionFrequency VALUES (2, 'I had an erection LESS THAN HALF the time I wanted one');
INSERT INTO mpower.ErectionFrequency VALUES (3, 'I had an erection ABOUT HALF the time I wanted one');
INSERT INTO mpower.ErectionFrequency VALUES (4, 'I had an erection MORE THAN HALF the time I wanted one');
INSERT INTO mpower.ErectionFrequency VALUES (5, 'I had an erection WHENEVER I wanted one');

CREATE TABLE mpower.LifeQuality
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    FourWeekFrequencyUrineLeaking INTEGER,
    FourWeekUrineControl INTEGER,
    FourWeekDiaperUse INTEGER,
    FourWeekProblemUrineLeaking INTEGER,
    FourWeekProblemUrinationPain INTEGER,
    FourWeekProblemUrinationBleeding INTEGER,
    FourWeekProblemUrinationWeakStream INTEGER,
    FourWeekProblemUrinationFrequently INTEGER,

    FourWeekProblemUrinationOverall INTEGER,
    ProblemBowelUrgency INTEGER,
    ProblemBowelFrequency INTEGER,
    ProblemStoolControl INTEGER,
    ProblemStoolBlood INTEGER,
    ProblemRectalPain INTEGER,

    FourWeekProblemBowel INTEGER,
    FourWeekAbilityErection INTEGER,
    FourWeekAbilityOrgasm INTEGER,

    FourWeekQualityErection INTEGER,
    FourWeekFrequencyErection INTEGER,
    FourWeekSexualFunction INTEGER,
    FourWeekSexualProblem INTEGER,
    FourWeekProblemHotFlash INTEGER,
    FourWeekProblemBreast INTEGER,
    FourWeekProblemDepression INTEGER,
    FourWeekProblemEnergy INTEGER,
    FourWeekProblemWeight INTEGER,

    CONSTRAINT PK_LifeQuality PRIMARY KEY (RowId),
    CONSTRAINT FK_LifeQuality_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics(PatientId),
    CONSTRAINT FK_FourWeekFrequencyUrineLeaking_UrineLeak FOREIGN KEY (FourWeekFrequencyUrineLeaking) REFERENCES mpower.UrineLeak(Id),
    CONSTRAINT FK_FourWeekUrineControl_UrineControl FOREIGN KEY (FourWeekUrineControl) REFERENCES mpower.UrineControl(Id),
    CONSTRAINT FK_FourWeekDiaperUse_DiaperUse FOREIGN KEY (FourWeekDiaperUse) REFERENCES mpower.DiaperUse(Id),

    CONSTRAINT FK_FourWeekProblemUrineLeaking_ProblemScale FOREIGN KEY (FourWeekProblemUrineLeaking) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemUrinationPain_ProblemScale FOREIGN KEY (FourWeekProblemUrinationPain) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemUrinationBleeding_ProblemScale FOREIGN KEY (FourWeekProblemUrinationBleeding) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemUrinationWeakStream_ProblemScale FOREIGN KEY (FourWeekProblemUrinationWeakStream) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemUrinationFrequently_ProblemScale FOREIGN KEY (FourWeekProblemUrinationFrequently) REFERENCES mpower.ProblemScale(Id),

    CONSTRAINT FK_FourWeekProblemUrinationOverall_ProblemScale FOREIGN KEY (FourWeekProblemUrinationOverall) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_ProblemBowelUrgency_ProblemScale FOREIGN KEY (ProblemBowelUrgency) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_ProblemBowelFrequency_ProblemScale FOREIGN KEY (ProblemBowelFrequency) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_ProblemStoolControl_ProblemScale FOREIGN KEY (ProblemStoolControl) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_ProblemStoolBlood_ProblemScale FOREIGN KEY (ProblemStoolBlood) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_ProblemRectalPain_ProblemScale FOREIGN KEY (ProblemRectalPain) REFERENCES mpower.ProblemScale(Id),

    CONSTRAINT FK_FourWeekProblemBowel_StandardScale FOREIGN KEY (FourWeekProblemBowel) REFERENCES mpower.StandardScale(Id),
    CONSTRAINT FK_FourWeekAbilityErection_StandardScale FOREIGN KEY (FourWeekAbilityErection) REFERENCES mpower.StandardScale(Id),
    CONSTRAINT FK_FourWeekAbilityOrgasm_StandardScale FOREIGN KEY (FourWeekAbilityOrgasm) REFERENCES mpower.StandardScale(Id),

    CONSTRAINT FK_FourWeekQualityErection_ErectionQuality FOREIGN KEY (FourWeekQualityErection) REFERENCES mpower.ErectionQuality(Id),
    CONSTRAINT FK_FourWeekFrequencyErection_ErectionFrequency FOREIGN KEY (FourWeekFrequencyErection) REFERENCES mpower.ErectionFrequency(Id),
    CONSTRAINT FK_FourWeekSexualFunction_StandardScale FOREIGN KEY (FourWeekSexualFunction) REFERENCES mpower.StandardScale(Id),

    CONSTRAINT FK_FourWeekSexualProblem_ProblemScale FOREIGN KEY (FourWeekSexualProblem) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemHotFlash_ProblemScale FOREIGN KEY (FourWeekProblemHotFlash) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemBreast_ProblemScale FOREIGN KEY (FourWeekProblemBreast) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemDepression_ProblemScale FOREIGN KEY (FourWeekProblemDepression) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemEnergy_ProblemScale FOREIGN KEY (FourWeekProblemEnergy) REFERENCES mpower.ProblemScale(Id),
    CONSTRAINT FK_FourWeekProblemWeight_ProblemScale FOREIGN KEY (FourWeekProblemWeight) REFERENCES mpower.ProblemScale(Id)
);

CREATE TABLE mpower.MedicalCondition
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created  DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    Condition NVARCHAR(256),
    Notes NVARCHAR(MAX),
    Cancer BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_MedicalCondition PRIMARY KEY (RowId),
    CONSTRAINT FK_MedicalCondition_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics (PatientId)
);

CREATE TABLE mpower.DaysOfExercise
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_DaysOfExercise PRIMARY KEY (Id)
);
INSERT INTO mpower.DaysOfExercise VALUES (0, 'None');
INSERT INTO mpower.DaysOfExercise VALUES (1, '1 day');
INSERT INTO mpower.DaysOfExercise VALUES (2, '2 days');
INSERT INTO mpower.DaysOfExercise VALUES (3, '3 days');
INSERT INTO mpower.DaysOfExercise VALUES (4, '4 days');
INSERT INTO mpower.DaysOfExercise VALUES (5, '5 days');
INSERT INTO mpower.DaysOfExercise VALUES (6, '6 days');
INSERT INTO mpower.DaysOfExercise VALUES (7, '7 days');

CREATE TABLE mpower.AttendSupportGroup
(
    Id INTEGER NOT NULL,
    Name NVARCHAR(256) NOT NULL,

    CONSTRAINT PK_AttendSupportGroup PRIMARY KEY (Id)
);
INSERT INTO mpower.AttendSupportGroup VALUES (0, 'Yes, one meeting');
INSERT INTO mpower.AttendSupportGroup VALUES (1, 'Yes, I have attended several meetings');
INSERT INTO mpower.AttendSupportGroup VALUES (2, 'Yes, I regularly attend support group meetings');
INSERT INTO mpower.AttendSupportGroup VALUES (3, 'No');

CREATE TABLE mpower.Lifestyle
(
    RowId INT IDENTITY(1, 1) NOT NULL,
    Container ENTITYID NOT NULL,
    Created  DATETIME,
    Modified DATETIME,

    PatientId ENTITYID NOT NULL,
    AlternateTherapySpecialDiet BIT NOT NULL DEFAULT 0,
    AlternateTherapyDietSupplement BIT NOT NULL DEFAULT 0,
    AlternateTherapyVitamin BIT NOT NULL DEFAULT 0,
    AlternateTherapyHomeopathy BIT NOT NULL DEFAULT 0,
    AlternateTherapyPhysical BIT NOT NULL DEFAULT 0,
    AlternateTherapyOriental BIT NOT NULL DEFAULT 0,
    AlternateTherapyPsychotherapy BIT NOT NULL DEFAULT 0,
    AlternateTherapyPrayer BIT NOT NULL DEFAULT 0,
    AlternateTherapyFaith BIT NOT NULL DEFAULT 0,
    AlternateTherapyMind BIT NOT NULL DEFAULT 0,
    AlternateTherapyOther NVARCHAR(256),
    AlternateTherapyNone BIT NOT NULL DEFAULT 0,

    Cigarettes BIT NOT NULL DEFAULT 0,
    CigarettesPerDayBeforeDiagnosis INTEGER,
    CigarettesPerDayCurrently INTEGER,
    YearsOfCigaretteUse INTEGER,

    Alcohol BIT NOT NULL DEFAULT 0,
    AlcoholPerDayBeforeDiagnosis INTEGER,
    AlcoholPerDayCurrently INTEGER,

    HeightFeet INTEGER,
    HeightInches INTEGER,
    Weight INTEGER,
    FourWeekDaysOfExercise INTEGER,
    AttendedProstateSupportGroup INTEGER,
    ProstateCancerExperience NVARCHAR(MAX),

    CONSTRAINT PK_Lifestyle PRIMARY KEY (RowId),
    CONSTRAINT FK_Lifestyle_PatientId_PatientDemographics FOREIGN KEY (PatientId) REFERENCES mpower.PatientDemographics (PatientId),
    CONSTRAINT FK_FourWeekDaysOfExercise_DaysOfExercise FOREIGN KEY (FourWeekDaysOfExercise) REFERENCES mpower.DaysOfExercise (Id),
    CONSTRAINT FK_AttendedProstateSupportGroup_AttendSupportGroup FOREIGN KEY (AttendedProstateSupportGroup) REFERENCES mpower.AttendSupportGroup (Id)
);
