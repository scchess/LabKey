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
PRM_AN_ID AS Id,
PRM_WORK_PERFORMED_DATE,
PR_PK AS prPk,
PR_PRM_FK AS prmFk,
PRM_PROJECT AS projectCode,
PRM_INVESTIGATOR AS performedBy,
PRM_CHARGE_ID AS accountId,
PRM_REPORT_COMPLETE AS enddate,
PRM_PRINT_DATE AS printDate,
PRM_APPROVED_DATE AS approvedDate,
PRM_PATHOLOGIST AS pathologist,
PR_REPORT_TYPE AS  reportType,
PR_DEATH_TYPE AS mannerOfDeath,
PR_COMMENTS AS remark,
PR_BODY_CONDITION AS bcs,
PR_HYDRATION AS hydrationLevel,
PR_PATH_RESIDENT AS assistant,
r.OBJECTID AS objectid,
CAST(CASE WHEN(r.DATE_TIME > mr.DATE_TIME)
  THEN
    r.DATE_TIME
  ELSE mr.DATE_TIME
END AS  TIMESTAMP) AS date_time
FROM
cnprcSrc.ZPATH_REPORT r
LEFT JOIN
cnprcSrc.ZPATH_REPORT_MASTER mr
ON
r.PR_PRM_FK = mr.PRM_PK
WHERE PR_REPORT_TYPE != 'BI';
