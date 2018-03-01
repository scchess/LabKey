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
HOG_CODE AS obsCode,
null AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_VISUAL_SIGNS_ONLY_FLAG IS NOT NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_1 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_1 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_2 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_2 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_3 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_3 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_4 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_4 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_5 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_5 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_6 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_6 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_7 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_7 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL

UNION ALL

SELECT
HOG_CODE AS obsCode,
HOG_SNOMED_CODE_8 AS snomedCode,
HOG_PREGNANCY_DISPLAY_FLAG AS pregnancyDisplayFlag,
HOG_VISUAL_SIGNS_ONLY_FLAG AS visualSignsOnlyFlag
FROM cnprcSrc.ZHEALTH_OBS_GLOSSARY WHERE HOG_SNOMED_CODE_8 IS NOT NULL AND HOG_VISUAL_SIGNS_ONLY_FLAG IS NULL;