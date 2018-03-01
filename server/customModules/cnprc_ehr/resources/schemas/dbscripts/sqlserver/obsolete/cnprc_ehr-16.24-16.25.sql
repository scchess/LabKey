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


CREATE TABLE cnprc_ehr.image_capture_device
(
  rowid INT IDENTITY(1,1) NOT NULL,
  device_modality nvarchar(20),
  device_type nvarchar(20),
  device_name nvarchar(50),
  description nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_CAPTURE_DEVICE PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_CAPTURE_DEVICE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);
GO

CREATE INDEX CNPRC_EHR_CAPTURE_DEVICE_CONTAINER_INDEX ON cnprc_ehr.image_capture_device (Container);
GO

CREATE TABLE cnprc_ehr.image_format
(
  rowid INT IDENTITY(1,1) NOT NULL,
  name nvarchar(15),
  extension nvarchar(3),
  mime_type nvarchar(20),
  description nvarchar(255),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE_FORMAT PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_IMAGE_FORMAT FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_IMAGE_FORMAT_CONTAINER_INDEX ON cnprc_ehr.image_format (Container);
GO

CREATE TABLE cnprc_ehr.image
(
  Id nvarchar(15) NOT NULL,
  owner_type nvarchar(20),
  owner_name nvarchar(30),
  create_unit nvarchar(30),
  modality nvarchar(20),
  device_type nvarchar(20),
  device_name nvarchar(50),
  subject_type nvarchar(20),
  subject_name nvarchar(25),
  subject_location nvarchar(25),
  subject_species nvarchar(25),
  subject_organ nvarchar(25),
  original_filename nvarchar(100),
  original_format_name nvarchar(10),
  original_format_extension nvarchar(5),
  original_width_pixels  int,
  original_height_pixels int,
  original_size_bytes  int,
  upload_by nvarchar(25),
  upload_timestamp datetime,
  upload_comment nvarchar(50),
  description nvarchar(500),
  public_yn nvarchar(1),
  image_repository nvarchar(10),
  stock_yn nvarchar(1),
  stock_approved_yn nvarchar(1),
  stock_approved_by nvarchar(25),
  stock_approved_timestamp datetime,
  release_approved_yn nvarchar(1),
  release_approved_by nvarchar(25),
  release_approved_timestamp datetime,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE PRIMARY KEY (id),
  CONSTRAINT FK_CNPRC_EHR_IMAGE FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE INDEX CNPRC_EHR_IMAGE_CONTAINER_INDEX ON cnprc_ehr.image (Container);
GO

CREATE TABLE cnprc_ehr.image_snomed
(
  rowid INT IDENTITY(1,1) NOT NULL,
  Id nvarchar(15) NOT NULL,
  snomed_pk int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE_SNOMED PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_IMAGE_SNOMED FOREIGN KEY (container) REFERENCES core.Containers (EntityId),
  UNIQUE(Id, snomed_pk)
);

CREATE INDEX CNPRC_EHR_IMAGE_SNOMED_CONTAINER_INDEX ON cnprc_ehr.image_snomed (Container);
GO

CREATE TABLE cnprc_ehr.image_pathology
(
  rowid INT IDENTITY(1,1) NOT NULL,
  Id nvarchar(15) NOT NULL,
  prm_pk int,
  objectid nvarchar(100),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_CNPRC_EHR_IMAGE_NECROPSY PRIMARY KEY (rowid),
  CONSTRAINT FK_CNPRC_EHR_IMAGE_NECROPSY FOREIGN KEY (container) REFERENCES core.Containers (EntityId),
  UNIQUE(Id, prm_pk)
);

CREATE INDEX CNPRC_EHR_IMAGE_PATHOLOGY_CONTAINER_INDEX ON cnprc_ehr.image_snomed (Container);
GO
