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
FDSC_PK AS fdb_sample_checkout_pk,
FDSC_UNIT AS unit,
FDSC_SAMPLE_FK AS sample_fk,
FDSC_DATE_THAWED AS thawed_date,
FDSC_VIALS_THAWED AS vials_thawed,
FDSC_SHIP_LOCATION AS ship_location,
FDSC_TECHNICIAN AS technician,
FDSC_COMMENT AS comments,
OBJECTID AS objectid,
DATE_TIME
FROM
cnprcSrc_fdb.ZFREEZERDB_SAMPLE_CHECKOUT;