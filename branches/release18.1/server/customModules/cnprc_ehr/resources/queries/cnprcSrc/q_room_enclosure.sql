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
TRIM(REPLACE(ENCL_ENCLOSURE_ID, ' ', ''))  AS room,
ENCL_FILE_STATUS AS file_status,
ENCL_INDOOR_OUTDOOR_FLAG AS indoorOutdoorFlag,
ENCL_MANAGEMENT_TYPE AS management_type,
ENCL_SUPERVISOR AS supervisor,
ENCL_WEIGHT_SHEET_FREQUENCY AS weight_sheet_frequency,
ENCL_FOOD_ID AS food_id,
ENCL_SUPPLEMENTAL_DIET AS supplemental_diet,
ENCL_REMARK AS remark,
(CASE WHEN ENCL_MH_ROOM_YN = 'Y' THEN 1 ELSE 0 END) AS isMhRoom,
ENCL_MH_GROUP AS mh_group
FROM cnprcSrc.ZENCLOSURE;