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
VI_SEQ_PK AS seqPk,
VI_ANIMAL_ID AS Id,
VI_SAMPLE_DATE,
VI_TEST_DATE AS testDate,
VI_TARGET AS target,
VI_VIRUS AS virus,
VI_TEST_METHOD AS method,
VI_SAMPLE_TYPE AS sampleType,
VI_PURPOSE AS purpose,
VI_RESULT AS result,
VI_OPTICAL_DENSITY AS opticalDensity,
VI_TITRATION AS titration,
VI_LAB AS lab,
VI_LOCATION AS location,
VI_COMMENT AS remark,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZVIROLOGY
WHERE VI_SAMPLE_DATE > to_date('01-01-1900', 'DD-MM-YYYY');
