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
/* vehicle-16.30-16.31.sql */

ALTER TABLE vehicle.Models
    ADD InitialReleaseYear INT;

/* vehicle-16.31-16.32.sql */

-- Drop tables / procedures for ETL testing from this schema; they've been moved to the etltest schema.
DROP TABLE vehicle.etl_source;
DROP TABLE vehicle.etl_target;
DROP TABLE vehicle.etl_target2;
DROP TABLE vehicle.transfer;
DROP TABLE vehicle.etl_180column_source;
DROP TABLE vehicle.etl_180column_target;
DROP TABLE vehicle.etl_delete;

DROP PROCEDURE vehicle.etlTest;
DROP PROCEDURE vehicle.etlTestResultSet;
-- This procedure wasn't being used
DROP PROCEDURE vehicle.etlMissingTransformRunId

-- These two tables seem to have been introduced for ETL testing, but were never used
DROP TABLE vehicle.owner;
DROP TABLE vehicle.ownerbackup;