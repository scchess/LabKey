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
PR_AN_ID AS Id,
PR_DATE,
PR_PROJECT AS projectCode,
POT_ORGAN AS organ,
PR_REPORT_TYPE AS reportType,
POT_TEXT AS remark,
ot.OBJECTID as objectid,
CAST(CASE WHEN(ot.DATE_TIME > pr.DATE_TIME)
  THEN
    ot.DATE_TIME
  ELSE pr.DATE_TIME
END AS TIMESTAMP) AS date_time
FROM
cnprcSrc.ZPATH_ORGAN_TEXT ot
LEFT JOIN
cnprcSrc.ZPATH_REPORT pr
ON
ot.POT_FK = pr.PR_PK;