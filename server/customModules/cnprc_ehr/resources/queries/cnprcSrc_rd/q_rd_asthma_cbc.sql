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
AC_CNPRC_ID AS Id,
AC_TEST_DATE,
AC_SEQPK AS seq_pk,
AC_COMMENT AS remark,
AC_TOT_WBC AS total_wbc,
AC_RBC AS rbc,
AC_HGB AS hgb,
AC_HCT AS hct,
AC_MCV AS mcv,
AC_MCH AS mch,
AC_MCHC AS mchc,
AC_PLATELETS AS platelets,
AC_PLAS_PROT AS plas_prot,
AC_FIBROGEN AS fibrogen,
AC_NEUT_BAND AS neut_band,
AC_NEUT_BAND_PER AS neut_band_per,
AC_NEUT_SEG AS neut_seg,
AC_NEUT_SEG_PER AS neut_seg_per,
AC_LYMPHOCYTE AS lymphocyte,
AC_LYMPHOCYTE_PER AS lymphocyte_per,
AC_MONOCYTE AS monocyte,
AC_MONOCYTE_PER AS monocyte_per,
AC_EOSINOPHIL AS eosinophil,
AC_EOSINOPHIL_PER AS eosinophil_pe,
AC_BASOPHIL AS basophil,
AC_BASOPHIL_PER AS basophil_per
FROM cnprcSrc_rd.ASTHMA_CBC

UNION ALL

SELECT
AC_CNPRC_ID AS Id,
AC_TEST_DATE,
NULL AS seq_pk,
AC_COMMENT AS remark,
AC_TOT_WBC AS total_wbc,
AC_RBC AS rbc,
AC_HGB AS hgb,
AC_HCT AS hct,
AC_MCV AS mcv,
AC_MCH AS mch,
AC_MCHC AS mchc,
AC_PLATELETS AS platelets,
AC_PLAS_PROT AS plas_prot,
AC_FIBROGEN AS fibrogen,
AC_NEUT_BAND AS neut_band,
AC_NEUT_BAND_PER AS neut_band_per,
AC_NEUT_SEG AS neut_seg,
AC_NEUT_SEG_PER AS neut_seg_per,
AC_LYMPHOCYTE AS lymphocyte,
AC_LYMPHOCYTE_PER AS lymphocyte_per,
AC_MONOCYTE AS monocyte,
AC_MONOCYTE_PER AS monocyte_per,
AC_EOSINOPHIL AS eosinophil,
AC_EOSINOPHIL_PER AS eosinophil_pe,
AC_BASOPHIL AS basophil,
AC_BASOPHIL_PER AS basophil_per
FROM cnprcSrc_rd.ASTHMA_CBC_LOAD;