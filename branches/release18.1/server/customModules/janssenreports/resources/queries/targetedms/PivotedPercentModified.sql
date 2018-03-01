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
	Request,
	Protein,
	ChainID,
	ModificationType,
	ModCount,
	StartIndex,
  ModifiedSequence,
	UnmodifiedSequence,
	SampleType,
	RunID,
	QCed,
	MAX(PercentModified) AS Percent
FROM
	UnionedPercentModified
GROUP BY
	ModifiedSequence,
	UnmodifiedSequence,
	StartIndex,
	ModCount,
	Request,
	ChainID,
	Protein,
	SampleType,
	ModificationType,
	RunID,
	QCed
PIVOT Percent BY SampleType IN ('R', 'H', 'L', 'C', 'M', 'T')