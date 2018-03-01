/*
 * Copyright (c) 2017 LabKey Corporation
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
  CASE WHEN c.cage IS NULL
    THEN c.room
  ELSE (c.room || c.cage)
  END          AS location,
  c.room,
  c.cage,
  c.cagePosition.row,
  c.cagePosition.columnIdx,
  c.cage_type,
  re.indoorOutdoorFlag

FROM ehr_lookups.cage c
  --find the cage located to the left
  LEFT JOIN ehr_lookups.cage lc
    ON (lc.cage_type != 'No Cage' AND c.room = lc.room AND c.cagePosition.row = lc.cagePosition.row AND
        (c.cagePosition.columnIdx - 1) = lc.cagePosition.columnIdx)
  JOIN cnprc_ehr.room_enclosure re ON re.room = c.room
  JOIN cnprc_ehr.cage_location_history clh on clh.location = c.room || c.cage and clh.to_date is null
  WHERE (clh.file_status = 'AC' and re.file_status = 'AC')

