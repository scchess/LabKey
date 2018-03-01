/*
 * Copyright (c) 2011 LabKey Corporation
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

TRUNCATE TABLE mergesync.testnamemapping;
ALTER TABLE mergesync.testnamemapping DROP COLUMN rowid;
ALTER TABLE mergesync.testnamemapping ALTER COLUMN servicename SET NOT NULL;
ALTER TABLE mergesync.testnamemapping ADD CONSTRAINT PK_testnamemapping PRIMARY KEY (servicename);
ALTER TABLE mergesync.testnamemapping ADD automaticresults bool default false;

DROP TABLE mergesync.mergetolkmapping;

CREATE TABLE mergesync.mergetolkmapping (
  mergetestname varchar(100) NOT NULL,
  servicename varchar(100),

  CONSTRAINT PK_mergetolkmapping PRIMARY KEY (mergetestname)
);

INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Albumin', 'ALB', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Amylase', 'AMYL', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Anaerobic Culture', 'ANCULT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('BASIC Chemistry Panel in-house', 'BASIC', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('CBC with automated differential', 'CBC', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Clotting panel', 'CLOTPL', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Comprehensive Chemistry Panel Send Out', 'CMP', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Chemistry panel with high density lipoprotein send out', 'CMPHDL', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Comprehensive Chemistry panel in-house', 'COMP', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('C-Reactive Protein', 'CRP', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('CSF analysis (WBC count & differential)', 'CSFCC', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('CSF Total Protein', 'CSFPRO', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Cerebral Spinal Fluid Total Protein – Send out', 'CSFTP', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Cerebral Spinal Fluid white blood count with differential', 'CSFWBC', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('BAL Fluid Analysis with Cytology', 'CYTO', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Cytology Send out', 'CYTO', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('CBC with manual differential', 'DIFF', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('WBC differential', 'DIFF', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Dermatophyte test medium culture', 'DTMFUN', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Fecal culture', 'F_CULT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Fecal parasite exam', 'F_PARA', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Fungus Culture', 'FUNGAL', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('General culture', 'GCULT1', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('High-density lipoprotein & Low-density lipoprotein (HDL & LDL)', 'HDLLDL', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Glycosolated hemoglobin  (HGBA1C)', 'HGBA1C', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('LDL', 'LDL', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Lipid panel in-house: Cholesterol, Triglyceride, HDL, LDL', 'LIPID', true);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Malaria Screen', 'MALA', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Miscellaneous in-house', 'MIS IN', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Bile Acids Post-prarandial', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Bile Acids Pre-prarandial', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Calcium, ionized', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Calcium, total', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('CSF Glucose', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Lipase', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Miscellaneous send out', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Phenobarbital', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Protein Electrophoresis-Total Protein', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Thyroid Panel', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Vitamin D (1,25 Dihydroxy)', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Vitamin D (250H)', 'MISOUT', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('RBC Morphology', 'MORPH', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Occult Blood', 'OCCBLD', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Reticulocyte count', 'RETIC', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Antibiotic Sensitivity', 'SENSI', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Urinalysis', 'URINE', false);
INSERT INTO mergesync.testnamemapping (servicename, mergetestname, automaticresults) VALUES ('Yersinia culture', 'YERSNA', false);

TRUNCATE TABLE mergesync.mergetolkmapping;
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('ALB', 'Albumin');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('AMYL', 'Amylase');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('ANCULT', 'Anaerobic Culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('BASIC', 'BASIC Chemistry Panel in-house');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CBC', 'CBC with automated differential');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CLOTPL', 'Clotting panel');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CMP', 'Comprehensive Chemistry Panel Send Out');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CMPHDL', 'Chemistry panel with high density lipoprotein send out');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('COMP', 'Comprehensive Chemistry panel in-house');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CRP', 'C-Reactive Protein');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CSFCC', 'CSF analysis (WBC count & differential)');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CSFPRO', 'CSF Total Protein');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CSFTP', 'Cerebral Spinal Fluid Total Protein – Send out');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CSFWBC', 'Cerebral Spinal Fluid white blood count with differential');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CYTO', 'BAL Fluid Analysis with Cytology');
--INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('CYTO', 'Cytology Send out');
--INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('DIFF', 'CBC with manual differential');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('DIFF', 'WBC differential');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('DTMFUN', 'Dermatophyte test medium culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('F_CULT', 'Fecal culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('F_PARA', 'Fecal parasite exam');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('FUNGAL', 'Fungus Culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('GCULT1', 'General culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('GCULT2', 'General culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('GCULT3', 'General culture');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('HDLLDL', 'High-density lipoprotein & Low-density lipoprotein (HDL & LDL)');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('HGBA1C', 'Glycosolated hemoglobin  (HGBA1C)');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('LDL', 'LDL');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('LIPID', 'Lipid panel in-house: Cholesterol, Triglyceride, HDL, LDL');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('MALA', 'Malaria Screen');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('MIS IN', 'Miscellaneous in-house');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('MISOUT', 'Miscellaneous send out');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('MORPH', 'RBC Morphology');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('OCCBLD', 'Occult Blood');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('RETIC', 'Reticulocyte count');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('SENS2', 'Antibiotic Sensitivity');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('SENS3', 'Antibiotic Sensitivity');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('SENSI', 'Antibiotic Sensitivity');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('URINE', 'Urinalysis');
INSERT INTO mergesync.mergetolkmapping (mergetestname, servicename) VALUES ('YERSNA', 'Yersinia culture');
