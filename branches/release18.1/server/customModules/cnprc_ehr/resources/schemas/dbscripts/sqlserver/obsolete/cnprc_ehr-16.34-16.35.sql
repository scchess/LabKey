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
CREATE INDEX CNPRC_EHR_CAGE_OBSERVATIONS_OBJECTID_INDEX ON cnprc_ehr.cage_observations (objectid);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_EXCEPTIONS_OBJECTID_INDEX ON cnprc_ehr.protocol_exceptions (objectid);
GO

CREATE INDEX CNPRC_EHR_BREEDING_ROSTER_OBJECTID_INDEX ON cnprc_ehr.breedingRoster (objectid);
GO

CREATE INDEX CNPRC_EHR_GERIATRIC_GROUPS_OBJECTID_INDEX ON cnprc_ehr.geriatricGroups (objectid);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_OBJECTID_INDEX ON cnprc_ehr.protocol (objectid);
GO

CREATE INDEX CNPRC_EHR_PROTOCOL_AMENDMENTS_OBJECTID_INDEX ON cnprc_ehr.protocol_amendments (objectid);
GO

CREATE INDEX CNPRC_EHR_IMAGE_OBJECTID_INDEX ON cnprc_ehr.image (objectid);
GO

CREATE INDEX CNPRC_EHR_IMAGE_SNOMED_OBJECTID_INDEX ON cnprc_ehr.image_snomed (objectid);
GO

CREATE INDEX CNPRC_EHR_IMAGE_PATHOLOGY_OBJECTID_INDEX ON cnprc_ehr.image_pathology (objectid);
GO

CREATE INDEX CNPRC_EHR_FDB_SAMPLE_CHECKOUT_OBJECTID_INDEX ON cnprc_ehr.fdb_sample_checkout (objectid);
GO

CREATE INDEX CNPRC_EHR_FDB_TISSUE_HARVEST_OBJECTID_INDEX ON cnprc_ehr.fdb_tissue_harvest (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_BLOCKS_OBJECTID_INDEX ON cnprc_ehr.path_inv_blocks (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_CHECKOUT_OBJECTID_INDEX ON cnprc_ehr.path_inv_checkout (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_FIXED_OBJECTID_INDEX ON cnprc_ehr.path_inv_fixed (objectid);
GO

CREATE INDEX CNPRC_EHR_PATH_INV_FROZEN_OBJECTID_INDEX ON cnprc_ehr.path_inv_frozen (objectid);
GO

CREATE INDEX CNPRC_EHR_KEY_ASSIGNMENTS_OBJECTID_INDEX ON cnprc_ehr.key_assignments (objectid);
GO

CREATE INDEX CNPRC_EHR_KEYS_OBJECTID_INDEX ON cnprc_ehr.keys (objectid);
GO

CREATE INDEX CNPRC_EHR_MH_FILE_OBJECTID_INDEX ON cnprc_ehr.mh_file (objectid);
GO

CREATE INDEX CNPRC_EHR_MH_DUMP_OBJECTID_INDEX ON cnprc_ehr.mh_dump (objectid);
GO

CREATE INDEX CNPRC_EHR_CENTER_UNIT_OBJECTID_INDEX ON cnprc_ehr.center_unit (objectid);
GO
