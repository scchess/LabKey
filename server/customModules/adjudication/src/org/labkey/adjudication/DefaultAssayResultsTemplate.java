/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
package org.labkey.adjudication;

import org.labkey.api.data.JdbcType;
import org.labkey.api.data.PropertyStorageSpec;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by davebradlee on 10/1/15.
 *
 */
public class DefaultAssayResultsTemplate implements AssayResultsTemplate
{
    private static final String BAND1_GP36 = "Band1-GP36";
    private static final String BAND2_GP140 = "Band2-GP140";
    private static final String BAND3_P31 = "Band3-P31";
    private static final String BAND4_GP160 = "Band4-GP160";
    private static final String BAND5_P24 = "Band5-P24";
    private static final String BAND6_GP41 = "Band6-GP41";
    private static final String CTRLBAND = "CTRLBand";
    private static final String ANALYTE = "Analyte";
    private static final String LABTESTNAME = "LabTestName";
    private static final String HIV1_INTERPRETATION = "HIV-1Interpretation";
    private static final String HIV2_INTERPRETATION = "HIV-2Interpretation";

    private static final List<PropertyStorageSpec> EXTRA_PROPERTIES;
    static
    {
        PropertyStorageSpec[] extraProps =
        {
            new PropertyStorageSpec(BAND1_GP36, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(BAND2_GP140, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(BAND3_P31, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(BAND4_GP160, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(BAND5_P24, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(BAND6_GP41, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(CTRLBAND, JdbcType.VARCHAR, 10),
            new PropertyStorageSpec(ANALYTE, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(LABTESTNAME, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(HIV1_INTERPRETATION, JdbcType.VARCHAR, 50),
            new PropertyStorageSpec(HIV2_INTERPRETATION, JdbcType.VARCHAR, 50)
        };
        EXTRA_PROPERTIES = Arrays.asList(extraProps);
    }

    public Set<PropertyStorageSpec> getExtraProperties()
    {
        return new LinkedHashSet<>(EXTRA_PROPERTIES);
    }
}
