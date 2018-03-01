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
SELECT count(adj.CaseId) AS TotalCases,
sum(CASE WHEN adj.StatusId.Status = 'Active Adjudication' THEN 1 ELSE 0 END) AS ActiveCases,
sum(CASE WHEN adj.StatusId.Status = 'Complete' THEN 1 ELSE 0 END) AS CompleteCases,
round(avg(TIMESTAMPDIFF('SQL_TSI_DAY', adj.Created, adj.Completed)),2) AS AveCompDays,
min(TIMESTAMPDIFF('SQL_TSI_DAY', adj.Created, adj.Completed)) AS MinCompDays,
max(TIMESTAMPDIFF('SQL_TSI_DAY', adj.Created, adj.Completed)) AS MaxCompDays,
round(avg(TIMESTAMPDIFF('SQL_TSI_DAY', adj.Completed, adj.LabVerified)),2) AS AveReceiptDays,
min(TIMESTAMPDIFF('SQL_TSI_DAY', adj.Completed, adj.LabVerified)) AS MinReceiptDays,
max(TIMESTAMPDIFF('SQL_TSI_DAY', adj.Completed, adj.LabVerified)) AS MaxReceiptDays
FROM AdjudicationCase adj
LEFT JOIN Status ON Status.RowId = adj.StatusId