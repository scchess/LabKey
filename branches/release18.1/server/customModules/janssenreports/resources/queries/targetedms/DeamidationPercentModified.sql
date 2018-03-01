/*
 * Copyright (c) 2016 LabKey Corporation
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
	ModifiedSequence,
	UnmodifiedSequence,
	ModCount,
	PeptideId,
	SampleFileId,
	AreaM,
	AreaM1,
	Proportion,
	Proportion1,
	AreaM * (Proportion1 / Proportion) AS ExpectedM1,
	(AreaM1 - (AreaM * (Proportion1 / Proportion))) AS ModifiedTotalArea,
	(AreaM1 - (AreaM * (Proportion1 / Proportion))) / (AreaM1 - (AreaM * (Proportion1 / Proportion)) + AreaM) AS PercentModified
FROM
(
	SELECT
    X.ModifiedSequence,
    X.UnmodifiedSequence,
    X.ModCount,
		X.SampleFileId,
    X.PeptideId,
		tci.Area AS AreaM,
		tci1.Area AS AreaM1,
		tci.TransitionId.IsotopeDistProportion AS Proportion,
		tci1.TransitionId.IsotopeDistProportion AS Proportion1
	FROM
	(
		SELECT
			pci1.PrecursorId.ModifiedSequence AS ModifiedSequence,
			pci2.PrecursorId.ModifiedSequence AS UnmodifiedSequence,
      (LENGTH(pci1.PrecursorId.ModifiedSequence) - LENGTH(pci2.PrecursorId.ModifiedSequence)) / 4 /* 5 is the length of '[+1]' */ AS ModCount,
			pci1.Id,
			pci1.PrecursorId.PeptideId AS PeptideId,
			pci1.SampleFileId
	FROM
			precursorchrominfo pci1,
			precursorchrominfo pci2
	WHERE
			pci1.PrecursorId.ModifiedSequence LIKE '%[+1]%' AND
-- 			REPLACE(pci1.PrecursorId.ModifiedSequence, '[+1]', '') = REPLACE(pci2.PrecursorId.ModifiedSequence, '[+1]', '') AND
-- 			pci1.PrecursorId.ModifiedSequence != pci2.PrecursorId.ModifiedSequence AND
			REPLACE(pci1.PrecursorId.ModifiedSequence, '[+1]', '') = pci2.PrecursorId.ModifiedSequence AND
			pci1.SampleFileId = pci2.SampleFileId AND
			pci1.id != pci2.id AND
			pci1.PrecursorId.Charge = pci2.PrecursorId.Charge
	GROUP BY
		pci1.PrecursorId.modifiedsequence,
		pci1.Id,
		pci2.PrecursorId.modifiedsequence,
		pci1.PrecursorId.PeptideId,
		pci1.samplefileid
	) X
	LEFT JOIN
			TransitionChromInfo tci ON (tci.PrecursorChromInfoId = x.Id AND tci.TransitionId.Fragment = 'M')
	LEFT JOIN
			TransitionChromInfo tci1 ON (tci1.PrecursorChromInfoId = x.Id AND tci1.TransitionId.Fragment = 'M+1')
	WHERE tci.Area > 0 OR tci1.Area > 0
) Y