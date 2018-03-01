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
FORMULA_CONTROL_PK AS formula_control_id,
(CASE WHEN FC_ACTIVE_YN = 'Y' THEN 1 ELSE 0 END) AS active,
FC_CONCENTRATION_UNITS AS concentration_units,
FC_DOSE_UNITS AS dose_units,
(CASE WHEN FC_DOSE_BY_WEIGHT_YN = 'Y' THEN 1 ELSE 0 END) AS dose_by_weight,
FC_TOTAL_DOSE_UNITS AS total_dose_units,
FC_TREATMENT_VOLUME_UNITS AS treatment_volume_units,
FC_SCALING_MULTIPLIER AS scaling_multiplier,
FC_COMMENT AS fc_comments
FROM cnprcSrc.ZPRIMED_FORMULA_CONTROL;