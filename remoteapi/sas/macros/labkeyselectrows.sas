/*
 * Copyright (c) 2009 LabKey Corporation
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

/*
	Retrieves data from the instance of LabKey Server previously specified in %setConnection.
*/
%macro labkeySelectRows(dsn=, baseUrl=&lk_baseUrl, folderPath=&lk_folderPath, schemaName=&lk_schemaName, queryName=&lk_queryName, viewName=, filter=, columns=, sort=, rowOffset=, maxRows=, showHidden=0, userName=, password=, containerFilter=);
	data _null_;
		length title $1000;
		title = cat("Schema: '", &schemaName, "', Query: '", &queryName, "'");

		%if &viewName ne %then %do;
			title = cat(title, ", View: '", &viewName, "'");
		%end;

		%_labkeySharedSelectRowsHandling(1);
%mend labkeySelectRows;