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
  sub.indoorOutdoor  || ' ' || sub.rate_class || ' ' || coalesce(sub.isHospital,'')   as housingType,
  count('x') as totalAnimals
FROM
  (SELECT
     CASE WHEN c.id IS NOT NULL OR h.room LIKE '%HO%'
       THEN 'Hospital' END AS isHospital,
     case
      when clh.rate_class = 'H' then 'Hospital'
      when clh.rate_class = 'I' then 'Infectious'
      when clh.rate_class = 'R' then 'Regular'
      when clh.rate_class = 'N' then 'Nursery'
      when clh.rate_class = 'F' then 'Field Cage'
      when clh.rate_class = 'C' then 'Corn Crib'
      when clh.rate_class = 'Q' then 'Quarantine'
      else clh.rate_class end as rate_class,
     case when re.indoorOutdoorFlag = 'I' then 'Indoor' else 'Outdoor' end as indoorOutdoor,
     count(*)
   FROM study.housing h
     JOIN cnprc_ehr.cage_location_history clh ON clh.location =
                                                 (CASE WHEN h.cage IS NULL
                                                   THEN h.room
                                                  ELSE (h.room || h.cage) END) and clh.to_date is null
      JOIN cnprc_ehr.room_enclosure re ON re.room = h.room
      LEFT JOIN study.cases c ON c.id = h.id AND c.enddate IS NULL AND c.admitType = 'H'
   WHERE h.enddate IS NULL
        and h.id.demographics.species = 'MMU'
) sub
GROUP BY sub.isHospital, sub.rate_class, sub.indoorOutdoor