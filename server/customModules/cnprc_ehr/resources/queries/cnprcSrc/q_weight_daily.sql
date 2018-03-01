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

/** Note: This additional ETL for weights is to avoid collision of pathology weights from ZPATH_REPORT with ZWEIGHING -
  * we want ZWEIGHING weights to be in LK first, which is handled by Weights ETL incrementally, and ETL will run this query
  * once daily at night (see weight_daily.xml). Also, see CNPRC Support Ticket: 30247.
  */

SELECT
PR_AN_ID AS Id,
PR_DATE AS weightDate,
(PR_BODY_WEIGHT_GRAMS / 1000) AS Weight,
NULL AS bodyConditionScore,
NULL AS weightTattooFlag,
OBJECTID AS objectid,
OBJECTID AS parentid,
DATE_TIME
FROM cnprcSrc.ZPATH_REPORT preport
WHERE
PR_BODY_WEIGHT_GRAMS IS NOT NULL AND
NOT EXISTS (SELECT NULL FROM cnprcSrc.ZWEIGHING weight WHERE weight.WT_AN_ID = preport.PR_AN_ID AND weight.WT_DATE = preport.PR_DATE)