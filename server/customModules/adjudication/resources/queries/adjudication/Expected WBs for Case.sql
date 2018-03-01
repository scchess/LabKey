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
SELECT visits.AdjudicationId,
visits.AdjudicationId.ParticipantId,
visits.Visit,
dates.DRAWDT AS DrawDt,
wb.Key AS WBKey,
wb.File AS WBImageFile,
wb.EntityId
FROM "Adjudication Visits" AS visits
JOIN (SELECT ar.ParticipantId,ar.SequenceNum,ar.DRAWDT
      FROM study."Assay Results" AS ar
      GROUP BY ar.ParticipantId,ar.SequenceNum,ar.DRAWDT)
      AS dates ON visits.AdjudicationId.ParticipantId = dates.ParticipantId
      AND visits.Visit = dates.SequenceNum
LEFT JOIN "WB Images" AS wb ON visits.AdjudicationId.ParticipantId = wb.ParticipantId
      AND visits.Visit = wb.Visit AND dates.DRAWDT = wb.DrawDt