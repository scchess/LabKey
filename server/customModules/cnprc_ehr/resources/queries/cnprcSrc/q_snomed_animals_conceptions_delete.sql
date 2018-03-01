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
OBJECTID || '-' || 'TOPOGRAPHY'  AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'TOPOGRAPHY'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_TOPOGRAPHY_CODE IS NULL

UNION ALL

SELECT
OBJECTID || '-' || 'MORPHOLOGY' AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'MORPHOLOGY'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_MORPHOLOGY_CODE IS NULL

UNION ALL

SELECT
OBJECTID || '-' || 'ETIOLOGY' AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'ETIOLOGY'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_ETIOLOGY_CODE IS NULL

UNION ALL

SELECT
OBJECTID || '-' || 'FUNCTION' AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'FUNCTION'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_FUNCTION_CODE IS NULL

UNION ALL

SELECT
OBJECTID || '-' || 'DISEASE' AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'DISEASE'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_DISEASE_CODE IS NULL

UNION ALL

SELECT
OBJECTID || '-' || 'PROCEDURE' AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'PROCEDURE'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_PROCEDURE_CODE IS NULL

UNION ALL

SELECT
OBJECTID || '-' || 'OCCUPATION' AS objectid,
DATE_TIME
FROM cnprcSrc.ASNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'D'

UNION ALL

SELECT
OBJECTID || '-' || 'OCCUPATION'  AS objectid,
DATE_TIME
FROM cnprcSrc.ZSNOMED WHERE DATE_TIME IS NOT NULL AND SNO_AUD_CODE = 'U' AND SNO_OCCUPATION_CODE IS NULL;

--data is not expected to be deleted from ZAN_SNOMED table; hence, deletes are not handled for that table.