/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
select
y.Id,
max(y.primaryProject) AS primaryProject,
max(y.secondaryProjects) AS secondaryProjects,
y.date,
y.project,
y.enddate,
y.protocol,
y.projectProtocolAssignDate,
y.projectProtocolRelDate
from(
select
x.Id,
(CASE WHEN x.assignmentStatus='P' then max(x.projectCode) END) AS primaryProject,
(CASE WHEN x.assignmentStatus='S' then Group_concat(x.projectCode, ', ') ELSE NULL END) AS secondaryProjects,
x.date,
x.project,
x.enddate,
x.protocol,
x.projectProtocolAssignDate,
x.projectProtocolRelDate
FROM assignment x where x.enddate is null
group by x.Id, x.assignmentStatus, x.date, x.project,
x.enddate, x.protocol, x.projectProtocolAssignDate, x.projectProtocolRelDate) y
group by y.Id, y.date, y.project, y.enddate, y.protocol, y.projectProtocolAssignDate, y.projectProtocolRelDate