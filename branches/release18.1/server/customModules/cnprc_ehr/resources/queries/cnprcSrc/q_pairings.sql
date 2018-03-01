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
p1.AP_AN_ID AS Id,
p2.AP_AN_ID AS pairedWithId,
p1.AP_PAIR_KEY AS pairId,
APM_START_DATE,
APM_END_DATE AS endDate,
APM_BEHAVIOR_CODE AS observation,
APM_COMMENT AS remark,
p1.OBJECTID ||'--'|| pm.OBJECTID as objectid,
CAST(CASE WHEN(p1.DATE_TIME > pm.DATE_TIME)
  THEN
    p1.DATE_TIME
  ELSE pm.DATE_TIME
END AS TIMESTAMP) AS date_time
FROM
cnprcSrc.ZAN_PAIRING p1
LEFT JOIN
cnprcSrc.ZAN_PAIRING_MASTER pm ON p1.AP_PAIR_KEY = pm.APM_PAIR_KEY
LEFT JOIN
cnprcSrc.ZAN_PAIRING p2 ON p2.AP_PAIR_KEY = p1.AP_PAIR_KEY AND p2.ap_an_id <> p1.ap_an_id;