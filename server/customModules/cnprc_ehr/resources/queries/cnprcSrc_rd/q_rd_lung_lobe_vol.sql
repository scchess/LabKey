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
ALLV_PK AS id,
ALLV_CNPRC_ID AS animalId,
ALLV_PROJ_CODE AS project_code,
ALLV_RT_MID_LOBE_VOL AS rt_mid_lobe_vol,
ALLV_RT_MID_LOBE_FIX AS rt_mid_lobe_fix,
ALLV_RT_CRA_LOBE_VOL AS rt_cra_lobe_vol,
ALLV_RT_CRA_LOBE_FIX AS rt_cra_lobe_fix,
ALLV_LT_CRA_LOBE_VOL AS lt_cra_lobe_vol,
ALLV_LT_CRA_LOBE_FIX AS lt_cra_lobe_fix,
ALLV_COMMENT AS llv_comments
FROM cnprcSrc_rd.ASTHMA_LUNG_LOBE_VOLUME;