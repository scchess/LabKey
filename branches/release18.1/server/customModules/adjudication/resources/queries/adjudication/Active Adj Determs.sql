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
user.DisplayName,
adj.Created,
adj.Comment,
det.Status,
adjUser.UserId,
det.TeamNumber,
det.Status AS StatusDisplay,
'Case ID ' || CAST(adj.CaseId AS VARCHAR) || ' (' || det.Status || ')' AS CaseDisplay
FROM AdjudicationCase AS adj
LEFT OUTER JOIN Determination AS det ON adj.CaseId = det.CaseId
LEFT OUTER JOIN Status AS stat ON adj.StatusId = stat.RowId
LEFT OUTER JOIN AdjudicationUser AS adjUser ON det.TeamNumber = adjUser.TeamNumber AND det.Container = adjUser.Container
LEFT OUTER JOIN core.Users AS user ON adjUser.UserId = user.UserId
WHERE stat.Status = 'Active Adjudication'