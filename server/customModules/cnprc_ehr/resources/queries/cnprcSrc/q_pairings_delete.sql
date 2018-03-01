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
aud_p.OBJECTID ||'--'|| pm.OBJECTID as objectid,
aud_p.DATE_TIME
FROM cnprcSrc_aud.AAN_PAIRING aud_p
LEFT JOIN
cnprcSrc.ZAN_PAIRING_MASTER pm
ON aud_p.AP_AN_ID = pm.APM_PAIR_KEY --in the etl query q_pairings, the join is on pair key (AP_PAIR_KEY = APM_PAIR_KEY); however, when the record gets deleted, in the audit table AP_AN_ID is the pair key.
WHERE AP_AUD_CODE = 'D'

UNION ALL

SELECT
p.OBJECTID ||'--'|| aud_pm.OBJECTID as objectid,
aud_pm.DATE_TIME
FROM cnprcSrc.AAN_PAIRING_MASTER aud_pm
LEFT JOIN
cnprcSrc.ZAN_PAIRING p
ON p.AP_PAIR_KEY = aud_pm.APM_PAIR_KEY
WHERE APM_AUD_CODE = 'D'

UNION ALL

SELECT
pairing_aud.OBJECTID ||'--'|| pm_aud.OBJECTID as objectid,
CAST(CASE WHEN(pairing_aud.DATE_TIME > pm_aud.DATE_TIME)
  THEN
    pairing_aud.DATE_TIME
  ELSE pm_aud.DATE_TIME
END AS TIMESTAMP) AS date_time
FROM
cnprcSrc_aud.AAN_PAIRING pairing_aud
LEFT JOIN
cnprcSrc.AAN_PAIRING_MASTER pm_aud ON pairing_aud.AP_AN_ID = pm_aud.APM_PAIR_KEY
WHERE pairing_aud.AP_AUD_CODE = 'D' AND pm_aud.APM_AUD_CODE = 'D'