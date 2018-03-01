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
ASS_PK AS skin_sen_pk,
ASS_CNPRC_ID AS id,
ASS_PROJ_CODE AS projectCode,
ASS_TEST_DATE,
ASS_WHEAL_POSITIVE_CONTROL AS wheal_positive_control,
ASS_WHEAL_NEGATIVE_CONTROL AS wheal_negative_control,
ASS_WHEAL_DUST_MITE AS wheal_dust_mite,
ASS_WHEAL_COCKROACH AS wheal_cockroach,
ASS_WHEAL_MOLD AS wheal_mold,
ASS_WHEAL_TREES AS wheal_trees,
ASS_WHEAL_WEEDS AS wheal_weeds,
ASS_WHEAL_GRASSES AS wheal_grasses,
ASS_WHEAL_ASCARID AS wheal_ascarid,
ASS_WHEAL_OFFSPRING_COMMENT AS wheal_offspring_comment,
ASS_COMMENT AS remark
FROM
cnprcSrc_rd.ASTHMA_SKIN_SENSITIZATION;