/*
 * Copyright (c) 2011-2012 LabKey Corporation
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
--moved to the laboratory module:
drop table if exists sequenceanalysis.species;
drop table if exists sequenceanalysis.sample_source;
drop table if exists sequenceanalysis.external_dbs;
drop table if exists sequenceanalysis.geographic_origins;
drop table if exists sequenceanalysis.dna_mol_type;
--drop table if exists sequenceanalysis.samples;

alter table sequenceAnalysis.sequence_readsets
  add column fileid integer
  ;