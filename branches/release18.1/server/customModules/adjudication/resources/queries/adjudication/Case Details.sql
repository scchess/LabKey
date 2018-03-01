/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
    AssayFileName AS "Uploaded File Name",
    CaseId,
    ParticipantId,
    NumVisits AS "Number of Visits",
    AssayLabel AS "Number of Assay Results by Type",
    COUNT(*) AS AssayLabelCount,
    Comment
FROM (
    SELECT
        adj.AssayFileName,
        adj.CaseId,
        adj.ParticipantId,
        vis.NumVisits,
        ar.AssayType,
        at.Label As AssayLabel,
        adj.Comment
    FROM AdjudicationCase AS adj
    LEFT JOIN (
        SELECT a.CaseId, count(a.Visit) AS NumVisits
        FROM Visit AS a GROUP BY a.CaseId
    ) AS vis ON adj.CaseId = vis.CaseId
    LEFT JOIN (
        SELECT
            CaseId,
            -- special case for EIA1, EIA2,...
            CASE WHEN AssayType LIKE 'eia%' THEN 'eia' ELSE AssayType END AS AssayType
        FROM AssayResults
    ) AS ar ON adj.CaseId = ar.CaseId
    LEFT JOIN AssayTypes AS at ON replace(lcase(ar.AssayType), ' ', '') = lcase(at.Name)
) AS details
GROUP BY AssayFileName, CaseId, ParticipantId, NumVisits, Comment, AssayLabel
PIVOT AssayLabelCount BY "Number of Assay Results by Type"