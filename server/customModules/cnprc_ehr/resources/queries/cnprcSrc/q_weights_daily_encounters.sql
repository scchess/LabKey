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

/** Created this additional weights encounters ETL query to match weight_daily.sql */

SELECT
PR_AN_ID AS Id,
PR_DATE AS weightDate,
OBJECTID AS encounterId,
OBJECTID AS objectId,
'Biopsy/Necropsy Weight' AS remark,
DATE_TIME
FROM cnprcSrc.ZPATH_REPORT preport
WHERE
PR_BODY_WEIGHT_GRAMS IS NOT NULL AND
NOT EXISTS (SELECT NULL FROM cnprcSrc.ZWEIGHING weight WHERE weight.WT_AN_ID = preport.PR_AN_ID AND weight.WT_DATE = preport.PR_DATE)