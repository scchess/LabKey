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
FORMULARY_NAME_PK AS formulary_name_id,
(CASE WHEN FORMULARY_NAME_ACTIVE_YN = 'Y' THEN 1 ELSE 0 END) AS active,
GENERIC_NAME AS generic_name,
TRADE_NAME AS trade_name,
NAME_QUALIFIER AS name_qualifier,
FORMULARY_CATEGORY AS category,
USAGE_COMMENT AS usage_comment,
CONCENTRATION_COMMENT AS concentration_comment,
DOSE_COMMENT AS dose_comment,
FREQUENCY_COMMENT AS frequency_comment,
(CASE WHEN RX_TYPE_C_CLINICAL_PRESCRIP_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_c_clinical_prescrip,
(CASE WHEN RX_TYPE_L_CLINICAL_LONGTERM_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_l_clinical_longterm,
(CASE WHEN RX_TYPE_N_CLINICAL_NONSCHED_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_n_clinical_nonsched,
(CASE WHEN RX_TYPE_S_SUPPLEMENT_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_s_supplement,
(CASE WHEN RX_TYPE_V_VITAMIN_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_v_vitamin,
(CASE WHEN RX_TYPE_X_EXPERIMENTAL_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_x_experimental,
(CASE WHEN RX_TYPE_I_CLINICAL_SOLITARY_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_i_clinical_solitary,
(CASE WHEN WIDE_RANGE_THERAPEUTIC_DRUG_YN = 'Y' THEN 1 ELSE 0 END) AS wide_range_therapeutic_drug,
DEFAULT_DOSE_UNITS AS default_dose_units,
DEFAULT_DOSE_PER_UNIT_MIN AS default_dose_per_unit_min,
DEFAULT_DOSE_PER_UNIT_MAX AS default_dose_per_unit_max,
SORT_ORDER_WITHIN_CATEGORY AS sort_order_within_category,
SNOMED_COMPONENT_1 AS snomed_component_1,
SNOMED_COMPONENT_2 AS snomed_component_2,
SNOMED_COMPONENT_3 AS snomed_component_3,
SNOMED_COMPONENT_4 AS snomed_component_4,
DEFAULT_BILLING_ITEM_CODE AS default_billing_item_code,
(CASE WHEN INCLUDE_IN_FORMULARY_BOOK_YN = 'Y' THEN 1 ELSE 0 END) AS include_in_formulary_book,
FORMULARY_BOOK_COMMENT AS formulary_book_comment,
FORMULARY_BOOK_ROUTES AS formulary_book_routes,
FORMULARY_BOOK_FREQUENCIES AS formulary_book_frequencies,
(CASE WHEN RX_TYPE_H_CLIN_SUPPLEMENTS_YN = 'Y' THEN 1 ELSE 0 END) AS rx_type_h_clin_supplements
FROM cnprcSrc.ZPRIMED_FORMULARY_NAME;