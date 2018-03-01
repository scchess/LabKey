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
objectid,
date_time
FROM cnprcSrc.AMH_OBS
WHERE MHO_AUD_CODE = 'D'

UNION ALL

SELECT
objectid,
date_time
FROM cnprcSrc_aud.AMH_PROCESSING
WHERE MHP_AUD_CODE = 'D';