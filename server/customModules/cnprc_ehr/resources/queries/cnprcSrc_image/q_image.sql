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
ID AS Id,
OWNER_TYPE AS owner_type,
OWNER_NAME AS owner_name,
CREATE_UNIT AS create_unit,
MODALITY AS modality,
DEVICE_TYPE AS device_type,
DEVICE_NAME AS device_name,
SUBJECT_TYPE AS subject_type,
SUBJECT_NAME AS subject_name,
SUBJECT_LOCATION AS subject_location,
SUBJECT_SPECIES AS subject_species,
SUBJECT_ORGAN AS subject_organ,
ORIGINAL_FILENAME AS original_filename,
ORIGINAL_FORMAT_NAME AS original_format_name,
ORIGINAL_FORMAT_EXTENSION AS original_format_extension,
ORIGINAL_WIDTH_PIXELS AS original_width_pixels,
ORIGINAL_HEIGHT_PIXELS AS original_height_pixels,
ORIGINAL_SIZE_BYTES AS original_size_bytes,
UPLOAD_BY AS upload_by,
UPLOAD_TIMESTAMP AS upload_timestamp,
UPLOAD_COMMENT AS upload_comment,
DESCRIPTION AS description,
(CASE WHEN PUBLIC_YN = 'Y' THEN 1 ELSE 0 END) AS is_public,
IMAGE_REPOSITORY AS image_repository,
(CASE WHEN STOCK_YN = 'Y' THEN 1 ELSE 0 END) AS is_stock,
(CASE WHEN STOCK_APPROVED_YN = 'Y' THEN 1 ELSE 0 END) AS is_stock_approved,
STOCK_APPROVED_BY AS stock_approved_by,
STOCK_APPROVED_TIMESTAMP AS stock_approved_timestamp,
(CASE WHEN RELEASE_APPROVED_YN = 'Y' THEN 1 ELSE 0 END) AS is_release_approved,
RELEASE_APPROVED_BY AS release_approved_by,
RELEASE_APPROVED_TIMESTAMP AS release_approved_timestamp,
OBJECTID AS objectid,
DATE_TIME AS date_time
FROM cnprcSrc_image.IMAGE;