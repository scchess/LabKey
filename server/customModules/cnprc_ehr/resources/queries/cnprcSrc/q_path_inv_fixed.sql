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
PFI_SEQ_PK AS path_inv_fixed_pk,
PFI_ANSEQ_FK AS anseq_fk,
PF_CABINET AS cabinet,
PF_BIN AS bin,
PF_COMMENT AS comments,
PFI_CHECK_SEQ_FK AS check_seq_fk,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZPATH_FIXED;