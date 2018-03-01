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
ML_PK AS id,
ML_AN_ID AS an_id,
ML_AN_SP_CODE AS species,
ML_CNPRC_ID AS animalId,
ML_PROJ_CODE_01 AS proj_code_1,
ML_PROJ_CODE_02 AS proj_code_2,
ML_TREATMENT AS treatment,
ML_STAGGER_GROUP AS stagger_group,
ML_AGE_CATEGORY AS age_category,
ML_BIRTHDATE AS birthdate,
ML_DEATH_DATE AS death_date,
ML_NECROPSY_WT_KG AS necropsy_wt_kg,
ML_SEX AS gender,
ML_BIRTHPLACE AS birthplace,
ML_DAM_ID AS dam,
ML_DAM_GENETICS_VERIFY AS dam_genetics_verify,
ML_SIRE_ID AS sire,
ML_SIRE_GENETICS_VERIFY AS sire_genetics_verify,
ML_GENETICS_COMMENT AS genetics_comment,
ML_COMMENT AS comments
FROM cnprcSrc_rd.MASTER_LIST;