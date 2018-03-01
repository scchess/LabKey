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
  mho.Id,
  mho.date,
  mho.location,
  Stuff(
    COALESCE(',' || mho.obsCode1, '') ||
    COALESCE(',' || mho.obsCode2, '') ||
    COALESCE(',' || mho.obsCode3, '') ||
    COALESCE(',' || mho.obsCode4, '') ||
    COALESCE(',' || mho.obsCode5, '') ||
    COALESCE(',' || mho.obsCode6, '') ||
    COALESCE(',' || mho.obsCode7, '') ||
    COALESCE(',' || mho.obsCode8, '') ||
    COALESCE(',' || mho.obsCode9, '') ||
    COALESCE(',' || mho.obsCode10, '')
  , 1, 1, '') as observation
FROM study.morningHealthObs mho