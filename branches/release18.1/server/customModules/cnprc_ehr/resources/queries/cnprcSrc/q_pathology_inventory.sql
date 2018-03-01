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
PI_ANSEQ_PK AS path_inv_pk,
PI_ANID AS Id,
PI_TYPE AS inventoryType,
PI_DATE,
PI_PROJECT AS projectCode,
PI_TISSUE_TYPE AS tissueType,
OBJECTID as objectid,
DATE_TIME
FROM cnprcSrc.ZPATH_INV;