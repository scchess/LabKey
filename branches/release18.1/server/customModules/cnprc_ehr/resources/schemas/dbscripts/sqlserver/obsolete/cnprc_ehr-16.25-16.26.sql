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

sp_rename 'cnprc_ehr.image_pathology.PK_CNPRC_EHR_IMAGE_NECROPSY', 'PK_CNPRC_EHR_IMAGE_PATHOLOGY';
GO

sp_rename 'cnprc_ehr.FK_CNPRC_EHR_IMAGE_NECROPSY', 'FK_CNPRC_EHR_IMAGE_PATHOLOGY';
GO

DROP INDEX CNPRC_EHR_IMAGE_PATHOLOGY_CONTAINER_INDEX ON cnprc_ehr.image_snomed;
GO
CREATE INDEX CNPRC_EHR_IMAGE_PATHOLOGY_CONTAINER_INDEX ON cnprc_ehr.image_pathology (Container);
GO

ALTER TABLE cnprc_ehr.image DROP COLUMN public_yn;
GO
ALTER TABLE cnprc_ehr.image DROP COLUMN stock_yn;
GO
ALTER TABLE cnprc_ehr.image DROP COLUMN stock_approved_yn;
GO
ALTER TABLE cnprc_ehr.image DROP COLUMN release_approved_yn;
GO

ALTER TABLE cnprc_ehr.image ADD is_public bit;
GO
ALTER TABLE cnprc_ehr.image ADD is_stock bit;
GO
ALTER TABLE cnprc_ehr.image ADD is_stock_approved bit;
GO
ALTER TABLE cnprc_ehr.image ADD is_release_approved bit;
GO