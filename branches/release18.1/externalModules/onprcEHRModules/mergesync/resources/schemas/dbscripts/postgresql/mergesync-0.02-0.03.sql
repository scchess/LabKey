/*
 * Copyright (c) 2011 LabKey Corporation
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

ALTER TABLE mergesync.orderssynced DROP COLUMN rowid;
ALTER TABLE mergesync.orderssynced ADD runid entityid;
ALTER TABLE mergesync.orderssynced ADD merge_datecreated timestamp;
ALTER TABLE mergesync.orderssynced ADD merge_dateposted timestamp;
ALTER TABLE mergesync.orderssynced ALTER COLUMN objectid SET not null;

ALTER TABLE mergesync.orderssynced ADD CONSTRAINT PK_orderssynced PRIMARY KEY (objectid);