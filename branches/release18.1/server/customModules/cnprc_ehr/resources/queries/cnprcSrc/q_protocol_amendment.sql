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
SElECT
PRTA_ID AS protocolAmendmentId,
PRTA_AUCAAC_NUMBER AS protocol,
(CASE WHEN PRTA_AMENDMENT_APPROVED_YN = 'Y' THEN 1 ELSE 0 END) AS approved,
PRTA_COMMITTEE_RESPONSE_DATE AS committeeResponseDate,
PRTA_SP1_ADDITIONAL_ALLOWED AS sp1AdditionalAllowed,
PRTA_SP2_ADDITIONAL_ALLOWED AS sp2AdditionalAllowed,
PRTA_AMENDMENT_COMMENT AS amendmentComments,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZPROTOCOL_AMENDMENT
WHERE
PRTA_ID IS NOT NULL;