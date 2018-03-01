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

SELECT
adj.CaseId AS CaseId,
adj.ParticipantId,
adj.Created,
adj.Completed,
det.Hiv1Infected AS Hiv1Infected,
det.Hiv2Infected AS Hiv2Infected,
vis1.Visit AS Hiv1InfectedVisit,
vis2.Visit AS Hiv2InfectedVisit,
MIN(res1.DrawDate) as Hiv1InfectedDate,
MIN(res2.DrawDate) as Hiv2InfectedDate
FROM Determination AS det
LEFT OUTER JOIN AdjudicationUser AS adjUser ON det.TeamNumber = adjUser.TeamNumber AND det.Container = adjUser.Container
LEFT OUTER JOIN Visit AS vis1 ON det.Hiv1InfectedVisit = vis1.RowId
LEFT OUTER JOIN Visit AS vis2 ON det.Hiv2InfectedVisit = vis2.RowId
LEFT OUTER JOIN AssayResults AS res1 ON vis1.Visit = res1.Visit AND det.CaseId = res1.CaseId
LEFT OUTER JOIN AssayResults AS res2 ON vis2.Visit = res2.Visit AND det.CaseId = res2.CaseId
LEFT OUTER JOIN AdjudicationCase AS adj ON det.CaseId = adj.CaseId
GROUP BY adj.CaseId, adj.ParticipantId, adj.Completed, adj.Created, vis1.Visit, vis2.Visit,
  det.Hiv1Infected, det.Hiv2Infected