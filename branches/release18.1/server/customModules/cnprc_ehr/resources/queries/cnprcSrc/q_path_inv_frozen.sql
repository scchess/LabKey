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
PFR_SEQ_PK AS path_inv_frozen_pk,
PFR_ANSEQ_FK AS anseq_fk,
PF_SHELF AS shelf,
PF_DRAWER AS drawer,
PF_BOX AS box,
upper(PF_TISSUE) AS tissue,
PF_COMMENT AS comments,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZPATH_FROZEN;
