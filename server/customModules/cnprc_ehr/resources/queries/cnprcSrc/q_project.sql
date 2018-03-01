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
PR_TRACKING_ID AS project_tracking_id,
PR_AN_REQUESTED_PER_YEAR AS an_requested_per_year,
PR_AN_USED_ASSIGNED AS an_used_assigned,
PR_AUCAAC_PROTOCOL_NUMBER AS protocol, -- this protocol does not always follow the updated convention for 12-12345.
CENTER_UNIT_CODE AS unitCode,
PR_DATE_PROTOCOL_SUB_AUCAAC AS date_protocol_sub_aucaac,
PR_DIRECT_AMT_RECEIVED AS direct_amt_received,
PR_DIRECT_AMT_REQUESTED_1 AS direct_amt_requested_1,
PR_DIRECT_AMT_REQUESTED_2 AS direct_amt_requested_2,
PR_FUNDING_AGENCY_1 AS funding_agency_1,
PR_FUNDING_AGENCY_2 AS funding_agency_2,
PR_GRANT_CONTRACT_ID AS grant_contract_id,
PR_OI_DEPARTMENT AS oi_department,
PR_OI_NAME AS oi_name,
PR_PI_DEPARTMENT AS pi_department,
PR_PI_NAME AS pi_name,
PR_ATTRIBUTES AS attributes,
PR_BEGIN_DATE AS startdate,
PR_CODE AS projectCode,
PR_COMMENTS AS comments,
PR_END_DATE AS enddate,
PR_TB_EXEMPT_FLAG AS tb_exempt_flag,
PR_TITLE AS title,
PR_TRACKING_STATUS AS tracking_status,
PR_PROPOSED_PR_END_DATE AS proposed_end_date,
PR_PROPOSED_PR_START_DATE AS proposed_start_date,
PR_PROTOCOL_END_DATE AS protocol_end_date,
PR_PROTOCOL_RESPONSE_DATE AS protocol_response_date,
PR_SP_REQUESTED AS sp_requested,
PR_TOTAL_AN AS total_animals,
PR_VISUAL_SIGNS_AUTO_RPT_FLAG AS visual_signs_auto_rpt_flag,
(CASE WHEN PR_PRPT_RECOGNIZE_YN = 'Y' THEN '1' ELSE '0' END) AS is_prpt_recognized,
PR_PI_AFFILIATION AS pi_affiliation,
PR_OI_AFFILIATION AS oi_affiliation,
(CASE WHEN PR_TISSUE_AVAIL_YN = 'Y' THEN '1' ELSE '0' END) AS is_tissue_avail,
PR_PI_PERSON_FK AS pi_person_fk,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZPROJECT project
WHERE
(PR_BEGIN_DATE IS NULL OR PR_BEGIN_DATE > to_date('01-01-1900', 'DD-MM-YYYY')) AND
(PR_PROTOCOL_END_DATE IS NULL OR PR_PROTOCOL_END_DATE > to_date('01-01-1900', 'DD-MM-YYYY')) AND
(PR_END_DATE IS NULL OR PR_END_DATE > to_date('01-01-1900', 'DD-MM-YYYY'));