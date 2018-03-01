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
FORMULARY_DOSING_PK AS formulary_dosing_id,
FORMULARY_NAME_FK AS formulary_name_fk,
(CASE WHEN DOSING_RECORD_ACTIVE_YN = 'Y' THEN 1 ELSE 0 END) AS dosing_record_active,
(CASE WHEN FORMULARY_DATA_COMPLETE_YN = 'Y' THEN 1 ELSE 0 END) AS formulary_data_complete,
DRUG_FORMAT_DESCRIPTION AS drug_format_description,
CONCENTRATION_UNITS AS concentration_units,
CONCENTRATION_PER_UNIT AS concentration_per_unit,
DOSE_UNITS AS dose_units,
DOSE_PER_UNIT AS dose_per_unit,
DOSE_PER_UNIT_MIN AS dose_per_unit_min,
DOSE_PER_UNIT_MAX AS dose_per_unit_max,
ROUTE AS route,
FREQUENCY AS frequency,
DAYS_DURATION AS days_duration,
TREATMENT_VOLUME_UNITS AS treatment_volume_units,
DOSE_SPECIFIC_COMMENT AS dose_specific_comment,
WEIGHT_RANGE_LOWER_LIMIT AS weight_range_lower_limit,
WEIGHT_RANGE_UPPER_LIMIT AS weight_range_upper_limit,
BILLING_ITEM_CODE AS billing_item_code,
FROM cnprcSrc.ZPRIMED_FORMULARY_DOSING;
