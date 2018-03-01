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
DI_AN_ID AS Id,
DI_OBS_DATE AS obsDate,
'Stool' AS category,
'L' AS observation,
DI_OBS_CODE AS code,
OBJECTID as objectid,
DATE_TIME
FROM cnprcSrc.ZDIARRHEA
UNION ALL
SELECT
PA_AN_ID AS Id,
PA_OBS_DATE AS obsDate,
'App' AS category,
'P' AS observation,
PA_OBS_CODE AS code,
OBJECTID as objectid,
DATE_TIME
FROM cnprcSrc.ZPOOR_APP