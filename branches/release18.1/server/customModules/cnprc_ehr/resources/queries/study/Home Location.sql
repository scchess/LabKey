/*
 * Copyright (c) 2017 LabKey Corporation
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
SELECT h1.id,
h1.reloc_seq,
h1.room,
h1.cage,
CASE
  WHEN h1.cage is null then h1.room
  ELSE (h1.room || h1.cage)
END AS Location
FROM study.housing h1
WHERE h1.reloc_seq=(
   SELECT
	coalesce(max(h2.reloc_seq),0)
   FROM study.housing h2
	WHERE h1.id = h2.id
	AND h2.room NOT LIKE 'HO%')