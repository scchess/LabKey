/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
CON_FEMALE_ID AS Id,
CON_FEMALE_SP AS femaleSpecies,
CON_MALE_ID AS sire,
CON_MALE_SP AS maleSpecies,
CON_OFFSPRING_ID AS offspringId,
CON_OFFSPRING_SP AS offspringSpecies,
CON_BIRTH_VIABILITY AS birthViability,
CON_DEATH_TYPE AS deathType,
CON_DEATH_NECROPSY_YN AS necropsyPerformed,
CON_DEATH_PATHOLOGIST AS pathologist,
CON_BIRTHPLACE AS birthPlace,
CON_OFFSPRING_SEX AS gender,
CON_DELIVERY_MODE AS deliveryMode,
CON_INVALID_PG_FLAG AS pgFlag,
CON_NO AS conNum,
CON_CON_DATE as conception,
CON_CON_DATE_STATUS AS conceptionDateStatus,
CON_ACCESSION_DATE AS con_accession_date,
CON_BR_TYPE AS BRType,
CON_COLONY_CODE AS colonyCode,
CON_PR_CODE AS PRCode,
CON_PG_COMMENT AS PGComment,
CON_TERM_DATE AS termDate,
CON_TERM_DATE_STATUS AS termDateStatus,
CON_TERM_COMMENT AS termComment,
CON_BIRTHPLACE_PREFIX AS birthPlacePrefix,
CON_PG_TYPE AS pgType,
CON_FEMALE_GENETICS_VERIFY AS femaleGeneticsVerify,
CON_MALE_GENETICS_VERIFY AS maleGeneticsVerify,
OBJECTID as objectid,
DATE_TIME
FROM cnprcSrc.ZCONCEPTION;