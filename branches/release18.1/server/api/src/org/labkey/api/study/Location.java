/*
 * Copyright (c) 2009-2017 LabKey Corporation
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

package org.labkey.api.study;

/**
 * A study specimen location, such as a clinic or specimen repository.
 * User: kevink
 * Date: May 27, 2009
 */
public interface Location extends StudyEntity
{
    int  getRowId();

    Boolean isEndpoint();

    Boolean isRepository();

    Boolean isSal();

    Boolean isClinic();

    String getLabUploadCode();

    String getLabwareLabCode();

    Integer getLdmsLabCode();

    Integer getExternalId();

    String getDisplayName();

    String getTypeString();

    String getDescription();

    String getStreetAddress();
    String getCity();
    String getGoverningDistrict();
    String getCountry();
    String getPostalArea();
}
