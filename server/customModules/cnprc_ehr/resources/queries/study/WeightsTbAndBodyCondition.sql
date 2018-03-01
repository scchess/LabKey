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
select sub.id,
sub.date,
max(weight) as weight,
max(TB) as TB,
max(test1) as test1,
max(test2) as test2,
max(weightTattooFlag) as weightTattooFlag,
max(bodyConditionScore) as bodyConditionScore,
max(roomAtTime) as location,
max(cageAtTime) as cage,
max(conNum) as conception,
max(daysPregnant) as daysPregnant
 from
(SELECT
coalesce(weight.Id,tb.Id) as id,
coalesce(weight.date,tb.date) as date,
 weight.weight as weight,
 case when (tb.Id is not null) then ('TB') end as TB,
case when (tb.test = 'Test1') then
(tb.testType || tb.site || tb.twentyFourHrsResult || tb.fortyEightHrsResult ||  tb.seventyTwoHrsResult)
end as Test1,
case when (tb.test = 'Test2') then
(tb.testType || tb.site || tb.twentyFourHrsResult || tb.fortyEightHrsResult ||  tb.seventyTwoHrsResult)
end as Test2,
weight.weightTattooFlag,
weight.bodyConditionScore,
h.room as roomAtTime,
h.cage as cageAtTime,
pc.conNum,
case when(pc.conNum is not null) THEN
  timestampdiff('SQL_TSI_DAY', conception, coalesce(weight.date,tb.date)) end AS daysPregnant
FROM weight
full outer join study.tb tb on tb.id = weight.id and cast(weight.date as date) = cast(tb.date as date)
LEFT JOIN study.demographics d ON d.id = COALESCE(weight.id, tb.id)
left join study.Housing h on COALESCE(weight.id, tb.id) = h.id
                         AND h.qcstate.publicdata = true and h.date <= COALESCE(weight.date,tb.date) AND COALESCE(weight.date,tb.date) < h.enddateTimeCoalesced
left join study.pregnancyConfirmations pc on COALESCE(weight.id, tb.id) = pc.id and pc.conception <= COALESCE(weight.date,tb.date) AND COALESCE(weight.date,tb.date) < pc.termDate
) sub
group by id, date




