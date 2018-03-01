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
SELECT
PP_ID AS pp_pk,
PP_PROJECT_ID AS projectCode,
PP_AUCAAC_NUMBER AS protocol_number,
PP_ASSIGNMENT_DATE AS pp_assignment_date,
PP_RELEASE_DATE AS pp_release_date,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZPROJECT_PROTOCOL;