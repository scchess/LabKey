/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

CREATE FUNCTION adjudication.handleUpgrade() RETURNS void AS $$
    BEGIN
      IF NOT EXISTS(SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'adjudicationtables') THEN
            EXECUTE 'CREATE SCHEMA adjudicationtables';
      END IF;
    END
$$ LANGUAGE plpgsql;

SELECT adjudication.handleUpgrade();

DROP FUNCTION adjudication.handleUpgrade();
