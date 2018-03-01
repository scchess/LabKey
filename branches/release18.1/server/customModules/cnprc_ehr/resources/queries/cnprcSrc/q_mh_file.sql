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
MHF_FILE_NO AS fileNo,
MHF_FILE_NAME AS fileName,
MHF_POST_TIMESTAMP AS postTimestamp,
MHF_POST_USER AS postUser,
MHF_READER_BEGIN_TIMESTAMP AS readerBeginTimestamp,
MHF_READER_NUMBER AS readerNumber,
MHF_READER_ATTENDANT AS readerAttendant,
MHF_READER_HEADER_1 AS readerHeader_1,
MHF_READER_HEADER_2 AS readerHeader_2,
MHF_HEADER_RECS AS headerRecs,
MHF_DATA_RECS AS dataRecs,
MHF_TRAILER_RECS AS trailerRecs,
MHF_READER_VALIDATION AS readerValidation,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZMH_FILE;