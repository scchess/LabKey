/*
 * Copyright (c) 2013-2015 LabKey Corporation
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

/* mothership-13.10-13.11.sql */

/* mothership-13.10-13.11.sql */

ALTER TABLE mothership.ExceptionStackTrace ADD ModifiedBy USERID;
ALTER TABLE mothership.ExceptionStackTrace ADD Modified DATETIME;

/* mothership-13.11-13.12.sql */

ALTER TABLE mothership.ServerInstallation ADD UsedInstaller bit NULL;
