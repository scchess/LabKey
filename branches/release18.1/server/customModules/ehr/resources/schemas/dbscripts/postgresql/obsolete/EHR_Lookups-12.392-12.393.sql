/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
ALTER TABLE ehr_lookups.treatment_frequency ADD active bool default true;
ALTER TABLE ehr_lookups.treatment_frequency DROP COLUMN legacyname;