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
WT_AN_ID AS Id,
WT_DATE,
'Test1' AS test,
WT_TB_TEST1_TYPE AS testType,
WT_TB_TEST1_SITE AS site,
WT_TB_TEST1_24 AS twentyFourHrsResult,
WT_TB_TEST1_48 AS fortyEightHrsResult,
WT_TB_TEST1_72 AS seventyTwoHrsResult,
WT_AUD_TIME AS entry_date_tm,
WT_AUD_USERID AS user_name,
(OBJECTID ||'-'|| 'Test1') AS objectid,
DATE_TIME
FROM
cnprcSrc.ZWEIGHING WHERE WT_TB_TEST1_TYPE IS NOT NULL
UNION ALL
SELECT
WT_AN_ID AS Id,
WT_DATE,
'Test2' AS test,
WT_TB_TEST2_TYPE AS testType,
WT_TB_TEST2_SITE AS site,
WT_TB_TEST2_24 AS twentyFourHrsResult,
WT_TB_TEST2_48 AS fortyEightHrsResult,
WT_TB_TEST2_72 AS seventyTwoHrsResult,
WT_AUD_TIME AS entry_date_tm,
WT_AUD_USERID AS user_name,
(OBJECTID ||'-'|| 'Test2') AS objectid,
DATE_TIME
FROM
cnprcSrc.ZWEIGHING WHERE WT_TB_TEST2_TYPE IS NOT NULL;
Order by WT_DATE;