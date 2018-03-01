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
SELECT d.id,
group_concat(f.flag) as "Hold Flags"
FROM demographics d
join study.flags f on f.Id = d.Id and f.isactive = true
join ehr_lookups.flag_codes fc on f.flag = fc.value and fc.title like '%HOLD%'
group by d.Id