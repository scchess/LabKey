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
	ModifiedSequence,
	UnmodifiedSequence,
	ModCount,
	PeptideId,
	PeptideId.StartIndex AS StartIndex,
	SampleFileId,
	AreaM,
	AreaM1,
	Proportion,
	Proportion1,
	AreaM * (Proportion1 / Proportion) AS ExpectedM1,
	(AreaM1 - (AreaM * (Proportion1 / Proportion))) AS ModifiedTotalArea,
	(AreaM1 - (AreaM * (Proportion1 / Proportion))) / (AreaM1 - (AreaM * (Proportion1 / Proportion)) + AreaM) AS PercentModified,
	(SELECT MAX(Value) FROM peptideannotation WHERE Name = 'QCed' AND PeptideId IN (Y.PeptideId, Y.PeptideId2)) AS QCed

FROM
(
	SELECT
    X.ModifiedSequence,
    X.UnmodifiedSequence,
    X.ModCount,
		X.SampleFileId,
    X.PeptideId,
    X.PeptideId2,
		tci.Area AS AreaM,
		tci1.Area AS AreaM1,
		tci.TransitionId.IsotopeDistProportion AS Proportion,
		tci1.TransitionId.IsotopeDistProportion AS Proportion1
	FROM
	(
		SELECT
			pciMod.PrecursorId.ModifiedSequence AS ModifiedSequence,
			pciUnmod.PrecursorId.ModifiedSequence AS UnmodifiedSequence,
      (LENGTH(pciMod.PrecursorId.ModifiedSequence) - LENGTH(pciUnmod.PrecursorId.ModifiedSequence)) / 6 /* 6 is the length of '[+1]' */ AS ModCount,
			pciUnmod.Id,
			pciUnmod.PrecursorId.PeptideId AS PeptideId,
			pciMod.PrecursorId.PeptideId AS PeptideId2,
			pciUnmod.SampleFileId
	FROM
			precursorchrominfo pciMod,
			precursorchrominfo pciUnmod
	WHERE
			pciMod.PrecursorId.ModifiedSequence LIKE '%[+1.0]%' AND
			REPLACE(pciMod.PrecursorId.ModifiedSequence, '[+1.0]', '') = pciUnmod.PrecursorId.ModifiedSequence AND
			pciMod.SampleFileId = pciUnmod.SampleFileId AND
			pciMod.id != pciUnmod.id AND
			pciMod.PrecursorId.Charge = pciUnmod.PrecursorId.Charge AND

			  -- Restrict to peptides that are marked as coeluting
			  (pciUnmod.PrecursorId.PeptideId IN (SELECT PeptideId FROM PeptideAnnotation pa1 WHERE pa1.Name = 'Coelute' AND pa1.Value = 'true') OR
	      pciMod.PrecursorId.PeptideId IN (SELECT PeptideId FROM PeptideAnnotation pa2 WHERE pa2.Name = 'Coelute' AND pa2.Value = 'true'))

	GROUP BY
		pciMod.PrecursorId.modifiedsequence,
		pciUnmod.Id,
		pciUnmod.PrecursorId.modifiedsequence,
		pciUnmod.PrecursorId.PeptideId,
		pciMod.PrecursorId.PeptideId,
		pciUnmod.samplefileid
	) X
	LEFT JOIN
			TransitionChromInfo tci ON (tci.PrecursorChromInfoId = x.Id AND tci.TransitionId.Fragment = 'M')
	LEFT JOIN
			TransitionChromInfo tci1 ON (tci1.PrecursorChromInfoId = x.Id AND tci1.TransitionId.Fragment = 'M+1')
	WHERE tci.Area > 0 OR tci1.Area > 0
) Y