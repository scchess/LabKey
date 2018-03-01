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
a.AN_ID AS Id,
a.AN_BIRTH_DATE,
a.AN_SEX AS gender,
a.AN_SP_CODE AS species,
TRIM(REPLACE(SUBSTRING(c.CON_BIRTHPLACE, 1, 7), ' ', '')) AS room,
TRIM(SUBSTRING(c.CON_BIRTHPLACE, 8, 2)) AS cage,
(CASE WHEN a.AN_BIRTH_DATE_EST = 'E' THEN 1 ELSE 0 END) AS date_type,
a.AN_BIRTH_VIABILITY AS birth_viability,
c.CON_CON_DATE AS conception,
c.CON_CON_DATE_STATUS AS conceptionDateStatus,
a.AN_BIRTH_DELIVERY_MODE AS "type", --birth_type
a.OBJECTID AS objectid,
CAST (GREATEST( IFNULL (a.DATE_TIME,to_date('01-01-1900', 'DD-MM-YYYY')),
                IFNULL (c.DATE_TIME,to_date('01-01-1900', 'DD-MM-YYYY')))
AS TIMESTAMP ) AS DATE_TIME
FROM cnprcSrc.ZANIMAL a
LEFT JOIN cnprcSrc.ZCONCEPTION c
ON a.AN_ID = c.CON_OFFSPRING_ID
WHERE a.AN_ACQ_TYPE = '0'