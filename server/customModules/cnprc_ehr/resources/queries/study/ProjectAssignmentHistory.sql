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
  assignment.Id,
  assignment.date,
  assignment.enddate,
  assignment.projectCode,
  assignment.assignmentStatus,
  assignment.projectCode.pi_name,
  assignment.projectCode.title,
  coalesce(projectProtocol.protocol_number, project.protocol) AS protocol,
  assignment.projectCode.unitCode
FROM
  study.assignment assignment
  INNER JOIN --this inner join is necessary because not all projectCodes have protocols in project_protocol table
  cnprc_ehr.project project
    ON project.projectCode = assignment.projectCode
  LEFT JOIN
  cnprc_ehr.project_protocol projectProtocol
    ON
      projectProtocol.projectCode = assignment.projectCode
      AND
      assignment.date < projectProtocol.pp_release_date
      AND
      (coalesce(assignment.enddate, now()) <= projectProtocol.pp_release_date);