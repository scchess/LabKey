/*
 * Copyright (c) 2016 LabKey Corporation
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
SELECT
ANIMID AS Id,
TEST_DAT,
DAYS_OLD AS daysOld,
BIGREAR AS bigRear,
SPF AS spf,
SAMP1 AS samp1,
SAMP2 AS samp2,
SAMP3 AS samp3,
SAMP4 AS samp4,
ZSAMP1 AS zsamp1,
ZSAMP2 AS zsamp2,
ZSAMP3 AS zsamp3,
ZSAMP4 AS zsamp4,
WBC AS wbc,
LYMPHO AS lympho,
CD4 AS cd4,
CD8 AS cd8,
HEMOGLOBIN AS hemoglobin,
HEMATOCRIT AS hemotocrit,
MCV AS mcv,
PLASMA_PROTEIN AS plasma_protein,
REARING AS rearing,
SERTCODE AS sertcode,
MAOACODE AS maoacode,
OBJECTID AS objectId,
OBJECTID AS parentId,
DATE_TIME
FROM cnprcSrc.ZBIO_BEHAVIORAL_ASSESSMENT
WHERE TEST_DAT IS NOT NULL AND TEST_DAT > to_date('01-01-1900', 'DD-MM-YYYY');
