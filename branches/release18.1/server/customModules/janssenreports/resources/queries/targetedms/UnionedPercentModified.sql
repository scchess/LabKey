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
	SUBSTRING(SkylineId, 0, LOCATE('_', SkylineId)) AS Request,
	SUBSTRING(SUBSTRING(SkylineId, LOCATE('_', SkylineId)+1, LENGTH(SkylineId) ), LOCATE('_', SUBSTRING(SkylineId, LOCATE('_', SkylineId)+1, LENGTH(SkylineId) ))+1, 1 ) AS SampleType,
 	SUBSTRING(Description, 0, LOCATE('_', Description)) AS ChainID,
	SUBSTRING(Description, LOCATE('_', Description) + 1, LENGTH(Description)) AS Protein,
  PercentModified,
	ModificationType,
	StartIndex,
-- 	Residue,
	RunId,
	QCed

FROM (
	SELECT
		ModifiedSequence,
		UnmodifiedSequence,
    SampleFileId,
    PeptideId,
    StartIndex,
    SampleFileId.SkylineId,
    PeptideId.PeptideGroupId.RunId AS RunId,
		PeptideId.PeptideGroupId.Description AS Description,
--     SUBSTRING(ModifiedSequence, LOCATE('[+16]', ModifiedSequence) - 1, 1) || (PeptideId.StartIndex + LOCATE('[+16]', ModifiedSequence) - 1) AS Residue,
    ModifiedTotalArea,
    UnmodifiedTotalArea,
    PercentModified,
    'Oxidation' AS ModificationType,
    ModCount,
    QCed
	FROM OxidationPercentModified

	UNION

	SELECT
		ModifiedSequence,
		UnmodifiedSequence,
    SampleFileId,
    PeptideId,
    StartIndex,
    SampleFileId.SkylineId,
    PeptideId.PeptideGroupId.RunId AS RunId,
		PeptideId.PeptideGroupId.Description AS Description,
--     SUBSTRING(ModifiedSequence, LOCATE('[+1]', ModifiedSequence) - 1, 1) || (PeptideId.StartIndex + LOCATE('[+1]', ModifiedSequence) - 1) AS Residue,
	  ModifiedTotalArea,
    UnmodifiedTotalArea,
    PercentModified,
    'Deamidation Separate' AS ModificationType,
    ModCount,
    QCed
	FROM DeamidationSeparatePercentModified

	UNION

  SELECT
		ModifiedSequence,
		UnmodifiedSequence,
    SampleFileId,
    PeptideId,
    StartIndex,
    SampleFileId.SkylineId,
		PeptideId.PeptideGroupId.RunId AS RunId,
		PeptideId.PeptideGroupId.Description AS Description,
--     SUBSTRING(ModifiedSequence, LOCATE('[+1]', ModifiedSequence) - 1, 1) || (PeptideId.StartIndex + LOCATE('[+1]', ModifiedSequence) - 1) AS Residue,
	  ModifiedTotalArea,
    AreaM AS UnmodifiedTotalArea,
    PercentModified,
    'Deamidation Coelute' AS ModificationType,
    ModCount,
    QCed
	FROM DeamidationCoelutePercentModified
) X