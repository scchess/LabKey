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
PRT_AUCAAC_NUMBER AS protocol,
PRT_TITLE AS title,
PRT_PI_PERSON_ID AS piPersonId,
PRT_BEGIN_DATE AS protocolBeginDate,
PRT_END_DATE AS protocolEndDate,
PRT_TYPE AS projectType,
PRT_ORIGINAL_AUCAAC AS originalProtocol,
PRT_CI_PERSON_ID AS ciPersonId,
(CASE WHEN PRT_APPROVED_YN = 'Y' THEN 1 ELSE 0 END) AS approved,
PRT_COMMITTEE_RESPONSE_DATE AS committeeResponseDate,
PRT_SP1_CODE AS sp1Code,
PRT_SP1_INITIAL_ALLOWED AS sp1InitialAllowed,
PRT_SP1_TOTAL_ALLOWED AS sp1TotalAllowed,
PRT_SP2_CODE AS sp2Code,
PRT_SP2_INITIAL_ALLOWED AS sp2InitialAllowed,
PRT_SP2_TOTAL_ALLOWED AS sp2TotalAllowed,
PRT_ANIMAL_ALERT_THRESHOLD AS animalAlertThreshold,
(CASE WHEN PRT_AIDS_RELATED_YN = 'Y' THEN 1 ELSE 0 END) AS aidsRelated,
(CASE WHEN PRT_PHS_RELATED_YN = 'Y' THEN 1 ELSE 0 END) AS phsRelated,
(CASE WHEN PRT_PRIMATE_PROJECT_YN = 'Y' THEN 1 ELSE 0 END) AS primateProject,
PRT_PROTOCOL_PAIN_CATEGORY AS protocolPainCategory,
(CASE WHEN PRT_PAIRING_EXEMPTION_YN = 'Y' THEN 1 ELSE 0 END) AS pairingExemption,
(CASE WHEN PRT_FOOD_EXEMPTION_YN = 'Y' THEN 1 ELSE 0 END) AS foodExemption,
PRT_STUDY_COMMENT AS studyComment,
(CASE WHEN PRT_RENEW_PROTOCOL_YN = 'Y' THEN 1 ELSE 0 END) AS renewProtocol,
PRT_AUCAAC_NUMBER_NO_YEAR AS protocolNumberYear,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZPROTOCOL;