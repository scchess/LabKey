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
det.RowId,
adj.CaseId AS CaseId,
det.Completed AS Completed,
det.Status AS Status,
det.LastUpdated AS LastUpdated,
det.LastUpdatedBy AS LastUpdatedBy,
det.TeamNumber AS AdjudicatorTeamNumber,
det.Hiv1Infected AS Hiv1Infected,
det.Hiv2Infected AS Hiv2Infected,
det.Hiv1Comment AS Hiv1Comment,
det.Hiv2Comment AS Hiv2Comment,
MIN(res1.DrawDate) as Hiv1InfectedDate,
MIN(res2.DrawDate) as Hiv2InfectedDate,
user.UserId,
user.Email,
user.DisplayName
FROM Determination AS det
LEFT OUTER JOIN AdjudicationUser AS adjUser ON det.TeamNumber = adjUser.TeamNumber AND det.Container = adjUser.Container
LEFT OUTER JOIN core.Users AS user ON adjUser.UserId = user.UserId
LEFT OUTER JOIN Visit AS vis1 ON det.Hiv1InfectedVisit = vis1.RowId
LEFT OUTER JOIN Visit AS vis2 ON det.Hiv2InfectedVisit = vis2.RowId
LEFT OUTER JOIN AssayResults AS res1 ON vis1.Visit = res1.Visit AND det.CaseId = res1.CaseId
LEFT OUTER JOIN AssayResults AS res2 ON vis2.Visit = res2.Visit AND det.CaseId = res2.CaseId
LEFT OUTER JOIN AdjudicationCase AS adj ON det.CaseId = adj.CaseId
GROUP BY adj.CaseId, det.Completed, det.Status, det.Hiv1Comment, det.Hiv2Comment,
  det.LastUpdated, det.LastUpdatedBy, det.TeamNumber, det.Hiv1Infected, det.Hiv2Infected, user.UserId, user.Email,
  user.DisplayName, det.RowId
