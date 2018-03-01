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
GPU_AN_ID AS Id,
GPU_DATE,
GPU_OLD_DAM AS oldParent,
GPU_NEW_DAM AS parent,
'Dam' AS relationship,
GPU_NOTE AS remark
FROM cnprcSrc.ZGEN_PARENT_UPDATES
UNION ALL
SELECT
GPU_AN_ID AS Id,
GPU_DATE,
GPU_OLD_SIRE AS oldParent,
GPU_NEW_SIRE AS parent,
'Sire' AS relationship,
GPU_NOTE AS remark
FROM cnprcSrc.ZGEN_PARENT_UPDATES;









