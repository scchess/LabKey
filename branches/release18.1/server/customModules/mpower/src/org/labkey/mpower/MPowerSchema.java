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

package org.labkey.mpower;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.dialect.SqlDialect;

public class MPowerSchema
{
    private static final MPowerSchema _instance = new MPowerSchema();
    public static final String NAME = "mpower";

    public static MPowerSchema getInstance()
    {
        return _instance;
    }

    private MPowerSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.mpower.MPowerSchema.getInstance()
    }

    public DbSchema getSchema()
    {
        return DbSchema.get(NAME, DbSchemaType.Module);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }

    public TableInfo getTableInfoParticipant()
    {
        return getSchema().getTable("Participant");
    }

    public TableInfo getTableInfoSurveyResponse()
    {
        return getSchema().getTable("SurveyResponse");
    }

    public TableInfo getTableInfoParticipantResponseMap()
    {
        return getSchema().getTable("ParticipantResponseMap");
    }

    public TableInfo getTableInfoPatientDemographics()
    {
        return getSchema().getTable("PatientDemographics");
    }

    public TableInfo getTableInfoInsurance()
    {
        return getSchema().getTable("Insurance");
    }

    public TableInfo getTableInfoClinicalDiagnosis()
    {
        return getSchema().getTable("ClinicalDiagnosis");
    }

    public TableInfo getTableInfoFamilyHistory()
    {
        return getSchema().getTable("FamilyHistory");
    }

    public TableInfo getTableInfoTreatment()
    {
        return getSchema().getTable("Treatment");
    }

    public TableInfo getTableInfoTreatmentType()
    {
        return getSchema().getTable("TreatmentType");
    }

    public TableInfo getTableInfoLifeQuality()
    {
        return getSchema().getTable("LifeQuality");
    }

    public TableInfo getTableInfoLifeStyle()
    {
        return getSchema().getTable("LifeStyle");
    }

    public TableInfo getTableInfoMedicalCondition()
    {
        return getSchema().getTable("MedicalCondition");
    }
}
