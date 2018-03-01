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
  y.Id,
  max(y.primaryProject)                 AS primaryProject,
  max(y.primaryProjectDate)             AS primaryProjectDate,
  max(y.secondaryProjects)              AS secondaryProjects,
  (SELECT group_concat(projectCode, ', ')
   FROM assignment
   WHERE id = y.id AND enddate IS NULL) AS activeProjects
FROM (
       SELECT
         x.Id,
         (CASE WHEN x.assignmentStatus = 'P'
           THEN max(x.projectCode) END) AS primaryProject,
         (CASE WHEN x.assignmentStatus = 'P'
           THEN max(x.date) END)        AS primaryProjectDate,
         (CASE WHEN x.assignmentStatus = 'S'
           THEN Group_concat(x.projectCode, ', ')
          ELSE NULL END)                AS secondaryProjects
       FROM assignment x
       WHERE x.enddate IS NULL
       GROUP BY x.Id, x.assignmentStatus) y
GROUP BY y.Id