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
ANEE_AN_ID AS Id,
ANEE_ASSIGNMENT_DATE,
ANEE_RELEASE_DATE AS releaseDate,
ANEE_SOCIAL_CODE AS socialCode,
ANEE_BEHAVIOR_CODES AS observation
FROM
cnprcSrc.ZAN_ENV_ENRICHMENT
WHERE
ANEE_ASSIGNMENT_DATE > to_date('01-01-1900', 'DD-MM-YYYY');