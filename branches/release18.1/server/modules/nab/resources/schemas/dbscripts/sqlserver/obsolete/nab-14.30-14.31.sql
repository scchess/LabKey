/*
 * Copyright (c) 2014-2015 LabKey Corporation
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

-- Rename NAb schema to nab. See #21853.
CREATE SCHEMA nab_xxx;
GO
ALTER SCHEMA nab_xxx TRANSFER NAb.CutoffValue;
ALTER SCHEMA nab_xxx TRANSFER NAb.NAbSpecimen;
DROP SCHEMA NAb;
GO

CREATE SCHEMA nab;
GO
ALTER SCHEMA nab TRANSFER nab_xxx.CutoffValue;
ALTER SCHEMA nab TRANSFER nab_xxx.NAbSpecimen;
DROP SCHEMA nab_xxx;
GO
