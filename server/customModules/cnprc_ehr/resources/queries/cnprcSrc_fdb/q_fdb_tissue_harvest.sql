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
th.FDTH_PK AS fdb_tissue_harvest_pk,
th.FDTH_UNIT AS unit,
th.FDTH_SAMPLE_FK AS sample_fk,
th.FDTH_TISSUE AS tissue,
th.FDTH_APPROACH AS approach,
thp.FDTH_COLUMN01 AS column1,
thp.FDTH_COLUMN02 AS column2,
thp.FDTH_COLUMN03 AS column3,
thp.FDTH_COLUMN04 AS column4,
th.FDTH_COLUMN10 AS notes,
th.FDTH_COMMENT AS comments,
th.OBJECTID AS objectid,
CAST (
  GREATEST(th.date_time, IFNULL (thp.date_time, to_date('01-01-1900', 'DD-MM-YYYY')))
AS TIMESTAMP) AS DATE_TIME
FROM
cnprcSrc_fdb.ZFREEZERDB_TISSUE_HARVEST th
LEFT JOIN
cnprcSrc_fdb.ZFREEZERDB_TH_PREFS thp
ON
thp.FDTH_UNIT = th.FDTH_UNIT
AND thp.FDTH_APPROACH = th.FDTH_APPROACH
AND thp.FDTH_TISSUE = th.FDTH_TISSUE;