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
  ac.Id,
  max(ac.date) as date,
  group_concat(ac.admitType)         AS admitTypes,
  group_concat(ac.problem, chr(10)) AS problems,
  group_concat(ac.remark, chr(10))  AS remarks,
  count(*)                          AS total
FROM study.activeCases ac
GROUP BY ac.id