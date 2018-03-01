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
BR_FEMALE_ID AS Id,
BR_BREEDING_DATE,
BR_MALE_ID AS sire,
BR_HOURS AS hours,
BR_OBS_CODE AS obsCode,
BR_CYCLE_DAY AS cycleDay,
BR_CYCLE_DAY1_DATE AS cycleStartDate,
OBJECTID as objectid,
DATE_TIME
FROM cnprcSrc.ZBREEDING
