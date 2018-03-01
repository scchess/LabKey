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
aud_d.OBJECTID ||'--'|| pr.OBJECTID AS objectid,
aud_d.DATE_TIME
FROM cnprcSrc_aud.APATH_DIAGNOSIS aud_d --delete in ZPATH_DIAGNOSIS removes one record in study.morphologicDiagnosis
LEFT JOIN
cnprcSrc.ZPATH_REPORT pr
ON aud_d.PD_FK = pr.PR_PK
WHERE PD_AUD_CODE = 'D'

UNION ALL

SELECT
d.OBJECTID ||'--'|| pr_aud.OBJECTID AS objectid,
pr_aud.DATE_TIME
FROM cnprcSrc_aud.APATH_REPORT pr_aud --delete in ZPATH_REPORT removes all records in study.morphologicDiagnosis where d.PD_FK = pr_aud.PR_PK
LEFT JOIN
cnprcSrc.ZPATH_DIAGNOSIS d
ON d.PD_FK = pr_aud.PR_PK
WHERE PR_AUD_CODE = 'D';

-- note: in q_morphologicDiagonsis.sql, we are also joining to ZSNOMED, but not handling the delete in ZSNOMED here, since deletes in ZSNOMED
-- shouldn't delete the data LK for this particular dataset, but merely just show the snomed columns to be null.
-- So, deletes in ZSNOMED table gets handled as updates.