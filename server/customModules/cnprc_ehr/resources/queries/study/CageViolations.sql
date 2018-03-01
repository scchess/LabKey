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
 SELECT p.Id,
 clh.cage_size,
 clh.cage_size_number,
case
	when (substring( p.observation, 0,2)= 'HO') then ('')
	else ( p.observation) end as Behavior_Code

FROM study.pairings p
join cnprc_ehr.cage_location_history clh on clh.location = p.Id.curLocation.Location
where p.Id.curLocation.Location is not null
and  p.enddate is null
and clh.to_date is null
and substring(p.id.curLocation.Room, 0,2) not in ('CC', 'NC')
and p.Id.demographics.calculated_status = 'Alive'
and (
      ( p.Id.MostRecentWeight.MostRecentWeight >= 10
        and p.Id.MostRecentWeight.MostRecentWeight < 15
		and coalesce(clh.cage_size_number, 4) <6
       )
   or (
        p.Id.MostRecentWeight.MostRecentWeight >= 15
      	 and coalesce(clh.cage_size_number, 4) in (4,6,8)
		)
   or (p.Id.MostRecentWeight.MostRecentWeight > 20)
)