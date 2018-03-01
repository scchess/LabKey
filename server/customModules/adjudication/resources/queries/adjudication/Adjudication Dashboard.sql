/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
adj.CaseId,
adj.ParticipantId,
stat.Status,
adj.Created,
adj.Completed,
adj.Notified,
adj.LabVerified,
det.Hiv1Infected,
det.Hiv2Infected,
det.TeamNumbers AS AdjudicatorTeamNumbers,
adj.Comment
FROM AdjudicationCase AS adj
LEFT JOIN Status AS stat ON adj.StatusId = stat.RowId
LEFT JOIN (
   SELECT 
   GROUP_CONCAT(Hiv1Infected) AS Hiv1Infected,
   GROUP_CONCAT(Hiv2Infected) AS Hiv2Infected,
   GROUP_CONCAT(TeamNumber) AS TeamNumbers,
   CaseId
   FROM Determination GROUP BY CaseId
) AS det ON adj.CaseId = det.CaseId