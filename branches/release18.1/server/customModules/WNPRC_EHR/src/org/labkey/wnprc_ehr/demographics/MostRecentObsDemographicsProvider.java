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
package org.labkey.wnprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.FieldKey;
import org.labkey.wnprc_ehr.WNPRC_EHRModule;

import java.util.HashSet;
import java.util.Set;

public class MostRecentObsDemographicsProvider extends AbstractDemographicsProvider
{
    public MostRecentObsDemographicsProvider(Module owner) {
        super(owner, "study", "demographicsMostRecentObs");
        _supportsQCState = false;
    }

    public String getName() {
        return "Most Recent Observation";
    }

    protected Set<FieldKey> getFieldKeys() {
        Set<FieldKey> keys = new HashSet<>();

        keys.add(FieldKey.fromString("lastObservationDate"));
        keys.add(FieldKey.fromString("lastObservationRemark"));
        keys.add(FieldKey.fromString("lastObservationFeces"));
        keys.add(FieldKey.fromString("lastObservationMenses"));
        keys.add(FieldKey.fromString("lastObservationOther"));
        keys.add(FieldKey.fromString("lastObservationBehavior"));
        keys.add(FieldKey.fromString("lastObservationBreeding"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query) {
        return ("study".equalsIgnoreCase(schema) && "obs".equalsIgnoreCase(query));
    }
}
