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
CKA_PK                as key_assignment_pk,
CKA_CK_FK             as key_fk,
CKA_CP_FK             as person_fk,
CKA_DATE_ISSUED       as date_issued,
CKA_DATE_RETURNED     as date_returned,
CKA_ASSIGNMENT_STATUS as status,
CKA_COMMENT           as comments,
OBJECTID              as objectid,
DATE_TIME
FROM cnprcSrc.ZCRPRC_KEY_ASSIGNMENT;