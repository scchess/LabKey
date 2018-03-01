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
  pre1.ModifiedSequence AS ModifiedSequence,
  pre2.ModifiedSequence AS UnmodifiedSequence,
  (LENGTH(pre1.ModifiedSequence) - LENGTH(pre2.ModifiedSequence)) / 6 /* 6 is the length of '[+1.0]' */ AS ModCount,
	pre1.PeptideId AS PeptideId,
	pre1.PeptideId.StartIndex AS StartIndex,
  pci1.SampleFileId,
	SUM(pci1.TotalArea) AS ModifiedTotalArea,
	SUM(pci2.TotalArea) AS UnmodifiedTotalArea,
  SUM(pci1.TotalArea) / SUM(pci1.TotalArea + pci2.TotalArea) AS PercentModified,
  (SELECT MAX(Value) FROM peptideannotation WHERE Name = 'QCed' AND PeptideId IN (pre1.PeptideId, pre2.PeptideId)) AS QCed
FROM
  precursorchrominfo pci1,
  precursorchrominfo pci2,
  precursor pre1,
  precursor pre2
WHERE
  pre1.ModifiedSequence LIKE '%[+1.0]%' AND
  REPLACE(pre1.ModifiedSequence, '[+1.0]', '') = pre2.ModifiedSequence AND
--   REPLACE(pre1.ModifiedSequence, '[+1]', '') = REPLACE(pre2.ModifiedSequence, '[+1]', '') AND
--   pre1.ModifiedSequence != pre2.ModifiedSequence AND
--   LENGTH(REPLACE(pre1.ModifiedSequence, '[+1]', '')) > LENGTH(pre2.ModifiedSequence) AND
  pci1.SampleFileId = pci2.SampleFileId AND
  pci1.id != pci2.id AND
  pci1.TotalArea + pci2.TotalArea > 0 AND
  pre1.Id = pci1.PrecursorId AND pre2.Id = pci2.PrecursorId
	AND pre1.Charge = pre2.Charge

	-- Filter out peptides that are marked as coeluting
	AND pre1.PeptideId NOT IN (SELECT PeptideId FROM PeptideAnnotation pa1 WHERE pa1.Name = 'Coelute' AND pa1.Value = 'true')
	AND pre2.PeptideId NOT IN (SELECT PeptideId FROM PeptideAnnotation pa2 WHERE pa2.Name = 'Coelute' AND pa2.Value = 'true')
GROUP BY
	pre1.modifiedsequence,
	pre2.modifiedsequence,
	pre1.PeptideId,
	pre1.PeptideId.StartIndex,
	pre2.PeptideId,
	pci1.samplefileid