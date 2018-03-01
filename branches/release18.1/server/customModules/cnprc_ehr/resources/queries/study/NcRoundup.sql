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
SELECT d.Id,
(SELECT GROUP_CONCAT(flag) from study.flags f where f.Id = d.Id and SUBSTRING (f.flag,1,3)='VAS') AS VAS,
case when d.Id.age.ageInDays > 6940 then 'X' end as Geriatric,
case when d.Id.curLocation.location != d.Id.homeLocation.location then d.Id.curLocation.location end as "hoLocation",
case --Serum
when
	(
	d.Id.age.ageInDays > 180
	and (
	    id.DemographicsMostRecentSerum.id is null
	    or
	    (
           id.DemographicsMostRecentSerum.DaysSinceSample > 180
           and
           (select count(*) from study.serum s where s.Id = d.Id group by s.Id) < 3
       ))
  )
then 'X'
when ((d.Id.age.ageInDays > 730)
      and
      	id.DemographicsMostRecentSerum.DaysSinceSample > 730
      )
then 'X'
end as SerumBank,

case --Tetanus
when (d.Id.age.ageInDays > 180 and (id.DemographicsMostRecentTetanus.id is null))then 'X'
when (d.Id.age.ageInDays > 180
      and id.DemographicsMostRecentTetanus.TetanusCount < 2
      and id.DemographicsMostRecentTetanus.DaysSinceTetanus > 365
     )then 'X'
when (d.Id.age.ageInDays > 730
      and id.DemographicsMostRecentTetanus.DaysSinceTetanus > 365
      and( id.DemographicsMostRecentTetanus.TetanusCount < 2
          or
          	id.DemographicsMostRecentTetanus.DaysSinceTetanus > 1825
          )

     )then 'X'
end as Tetanus,

case -- Measles
when (d.Id.age.ageInDays > 180
      and
      NOT EXISTS (SELECT * from study.drug dr WHERE dr.Id = d.Id AND SUBSTRING (code,1,1) IN ('M','K'))
      and Id.DemographicsActivePregnancy.Id is null
	  and (Id.activeFlagList.values is null or Id.activeFlagList.values not like '%NOVA%')
      )
THEN 'X' END AS Measles,

case when( EXISTS(Select * from study.flags f where f.Id = d.Id and (flag like '%AN%' or flag  like '%AP%')))
then '' else 'X' end as VGL,

case -- Dam
when d.Id.age.ageInDays < 365
then Id.Demographics.Dam END as Dam


FROM demographics d
where d.calculated_status = 'Alive'