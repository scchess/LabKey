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
SELECT id,
(select 'HGL2' where flags.values like '%HGL2%') "HGL2",
(select 'HJS2' where flags.values like '%HJS2%') "HJS2",
(select 'HLH2' where flags.values like '%HLH2%') "HLH2",
(select 'HODK' where flags.values like '%HODK%') "HODK",
(select 'HOGL' where flags.values like '%HOGL%') "HOGL",
(select 'HOJS' where flags.values like '%HOJS%') "HOJS",
(select 'HOJV' where flags.values like '%HOJV%') "HOJV",
(select 'HOLG' where flags.values like '%HOLG%') "HOLG",
(select 'HOLH' where flags.values like '%HOLH%') "HOLH",
(select 'HOMS' where flags.values like '%HOMS%') "HOMS",
(select 'HOPM' where flags.values like '%HOPM%') "HOPM",
(select 'HOSG' where flags.values like '%HOSG%') "HOSG",
(select 'HOVB' where flags.values like '%HOVB%') "HOVB",
(select 'HOVL' where flags.values like '%HOVL%') "HOVL",
(select 'HOWA' where flags.values like '%HOWA%') "HOWA",
(select 'HOYK' where flags.values like '%HOYK%') "HOYK",
(select 'HYK2' where flags.values like '%HYK2%') "HYK2"
from study.DemographicsActiveFlags flags