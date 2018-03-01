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
CENTER_UNIT_SEQPK,
CENTER_UNIT_CODE,
CENTER_UNIT_TITLE,
CENTER_UNIT_DEPARTMENT,
CENTER_UNIT_COMMENT,
CENTER_UNIT_ACTIVE,
CENTER_UNIT_KEY,
CENTER_UNIT_RECORD_CLASS,
GENERAL_REPORTS_SORT_ORDER,
GRANT_REPORTS_SORT_ORDER,
FINANCIAL_RPTS_ROUTED_TO_CP_FK AS FIN_RPTS_ROUTED_TO_CP_FK
FROM
cnprcSrc.ZCENTER_UNIT;