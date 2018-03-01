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
-- need to parse the bead number off of the negative bead name and trim the analyte name
UPDATE luminex.Analyte SET Name = TRIM(both FROM Name),
  NegativeBead =
    CASE WHEN STRPOS(REVERSE(RTRIM(NegativeBead)), ')') = 1 THEN
      TRIM(both FROM SUBSTRING(NegativeBead, 1, LENGTH(NegativeBead) - STRPOS(REVERSE(NegativeBead), '(')))
    ELSE NegativeBead END;

-- trim the analyte name from the guide set table
UPDATE luminex.GuideSet SET AnalyteName = TRIM(both FROM AnalyteName);
