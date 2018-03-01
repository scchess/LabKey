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
PR_AN_ID AS Id,
PR_DATE,
PR_PROJECT AS projectCode,
PD_SEQ AS seq1,
SNO_TOPOGRAPHY_CODE AS tissue,
PR_REPORT_TYPE AS reportType,
SNO_MORPHOLOGY_CODE AS morphology,
SNO_ETIOLOGY_CODE AS etiology,
SNO_FUNCTION_CODE AS diagnosis,
SNO_DISEASE_CODE AS disease,
SNO_PROCEDURE_CODE AS process,
SNO_OCCUPATION_CODE AS distribution,
PD_TEXT_TOPOGRAPHY AS topographyNotes,
PD_TEXT_MORPHOLOGY AS morphologyNotes,
PD_TEXT_OTHER AS remark,
PD_COMMENT AS comments,
d.OBJECTID ||'--'|| pr.OBJECTID AS objectid,
CAST (
  GREATEST( IFNULL (d.date_time,to_date('01-01-1900', 'DD-MM-YYYY')),
            IFNULL (pr.date_time,to_date('01-01-1900', 'DD-MM-YYYY')),
            IFNULL (s.date_time,to_date('01-01-1900', 'DD-MM-YYYY')),
            IFNULL ((SELECT max(aud_sno.DATE_TIME) FROM cnprcSrc.ASNOMED aud_sno WHERE aud_sno.SNO_AUD_CODE = 'D'),
                    to_date('01-01-1900', 'DD-MM-YYYY')) --note: running this query with d.PD_SNOMED_FK = aud_sno.SNO_PK check was affecting the performance significantly; hence, resorted to getting max(date) from the audit table. This will check for all records for updates during ETL when data from ZSNOMED is deleted, however, this is faster than running the query with the SNO_PK check.
          )
AS TIMESTAMP ) AS DATE_TIME
FROM cnprcSrc.ZPATH_DIAGNOSIS d
LEFT JOIN
cnprcSrc.ZPATH_REPORT pr
ON d.PD_FK = pr.PR_PK
LEFT JOIN cnprcSrc.ZSNOMED s
ON d.PD_SNOMED_FK = s.SNO_PK
WHERE PR_DATE > to_date('01-01-1900', 'DD-MM-YYYY');
