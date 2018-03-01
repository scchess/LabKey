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
  assignAlive.Id,
  assignAlive.date                AS projectDate,
  assignAlive.assignmentStatus    AS projectType,
  assignAlive.projectCode         AS projectId,
  assignAlive.projectCode.pi_name AS pi,
  assignAlive.projectCode.title   AS projectName,
  assignAlive.QCState.publicdata  -- needed for some higher-up wrapping query somehow
FROM study.assignment assignAlive
JOIN study.demographics demoAlive
  ON demoAlive.Id = assignAlive.Id
 AND demoAlive.calculated_status = 'Alive'
WHERE assignAlive.enddate IS NULL

UNION ALL

SELECT
  assignDead.Id,
  assignDead.date                AS projectDate,
  assignDead.assignmentStatus    AS projectType,
  assignDead.projectCode         AS projectId,
  assignDead.projectCode.pi_name AS pi,
  assignDead.projectCode.title   AS projectName,
  assignDead.QCState.publicdata  -- needed for some higher-up wrapping query somehow
FROM study.assignment assignDead
JOIN study.demographics demoDead
  ON demoDead.Id = assignDead.Id
 AND demoDead.calculated_status <> 'Alive'
WHERE CAST(assignDead.enddate AS DATE) =
  (SELECT MAX(CAST(assignDead2.enddate AS DATE))
   FROM study.assignment assignDead2
   WHERE assignDead2.Id = assignDead.Id)