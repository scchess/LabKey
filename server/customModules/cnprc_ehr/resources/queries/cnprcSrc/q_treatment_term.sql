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
TREATMENT_TERM_PK AS treatment_term_id,
TERM_TYPE AS term_type,
TREATMENT_TERM AS treatment_term,
DEFINITION AS definition,
SNOMED_COMPONENT AS snomed_component,
(CASE WHEN ACTIVE_YN = 'Y' THEN 1 ELSE 0 END) AS active,
SORT_ORDER AS sort_order,
TERM_COMMENT AS term_comment
FROM cnprcSrc.ZPRIMED_TREATMENT_TERM;