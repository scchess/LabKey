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
PRM_AN_ID AS Id,
PRM_WORK_PERFORMED_DATE,
PRM_PROJECT AS projectCode,
PRM_REPORT_COMPLETE AS enddate,
PNM_NAME AS tissue,
PNM_VALUE AS measurementValue,
PMT_UNIT AS unit,
nm.OBJECTID as objectid,
CAST (
  GREATEST( IFNULL (nm.date_time,to_date('01-01-1900', 'DD-MM-YYYY')),
            IFNULL (mt.date_time,to_date('01-01-1900', 'DD-MM-YYYY')),
            IFNULL (rm.date_time,to_date('01-01-1900', 'DD-MM-YYYY')))
AS TIMESTAMP ) AS DATE_TIME
FROM
cnprcSrc.ZPATH_NECROPSY_MEASUREMENTS nm
LEFT JOIN
cnprcSrc.ZPATH_MEASUREMENT_TYPES mt
ON nm.PNM_NAME = mt.PMT_NAME
LEFT JOIN
cnprcSrc.ZPATH_REPORT_MASTER rm
ON nm.PNM_PRM_FK = rm.PRM_PK;