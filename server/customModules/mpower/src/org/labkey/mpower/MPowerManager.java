/*
 * Copyright (c) 2015 LabKey Corporation
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

import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.BeanObjectFactory;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.security.Encryption;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.GUID;
import org.labkey.mpower.model.ActivityTracker;
import org.labkey.mpower.model.ClinicalDiagnosis;
import org.labkey.mpower.model.FamilyHistory;
import org.labkey.mpower.model.Insurance;
import org.labkey.mpower.model.LifeQuality;
import org.labkey.mpower.model.Lifestyle;
import org.labkey.mpower.model.MedicalCondition;
import org.labkey.mpower.model.ParticipantResponseMap;
import org.labkey.mpower.model.PatientDemographics;
import org.labkey.mpower.model.SurveyParticipant;
import org.labkey.mpower.model.Treatment;
import org.labkey.mpower.model.TreatmentType;
import org.labkey.remoteapi.RemoteConnections;

import java.util.Map;

public class MPowerManager
{
    private static final Logger _log = Logger.getLogger(MPowerManager.class);
    private static final MPowerManager _instance = new MPowerManager();
    private static final BeanObjectFactory<PatientDemographics> PATIENT_DEMOGRAPHICS_FACTORY = new BeanObjectFactory<>(PatientDemographics.class);
    private static final BeanObjectFactory<ClinicalDiagnosis> CLINICAL_DIAGNOSIS_FACTORY = new BeanObjectFactory<>(ClinicalDiagnosis.class);
    private static final BeanObjectFactory<Treatment> TREATMENT_FACTORY = new BeanObjectFactory<>(Treatment.class);
    private static final BeanObjectFactory<LifeQuality> LIFE_QUALITY_FACTORY = new BeanObjectFactory<>(LifeQuality.class);
    private static final BeanObjectFactory<Lifestyle> LIFE_STYLE_FACTORY = new BeanObjectFactory<>(Lifestyle.class);
    private static final BeanObjectFactory<ActivityTracker> ACTIVITY_TRACKER_FACTORY = new BeanObjectFactory<>(ActivityTracker.class);
    public static final String MPOWER_ACTIVITY_TRACKER_PROPERTIES = "MPowerActivityTrackerSettings";

    // remote source name of the secure mpower server
    public static final String REMOTE_SOURCE_NAME = "mpower-remote-source";

    private MPowerManager()
    {
        // prevent external construction with a private default constructor
    }

    public static MPowerManager get()
    {
        return _instance;
    }

    /**
     * Save the survey participant, add the participant to the mapping table and return
     * the GUID so that survey responses can be linked later.
     * @param participant
     * @return
     */
    public String saveSurveyParticipant(User user, Container container, SurveyParticipant participant)
    {
        try (DbScope.Transaction transaction = MPowerSchema.getInstance().getSchema().getScope().ensureTransaction())
        {
            participant.beforeInsert(user, container.getId());
            participant = Table.insert(user, MPowerSchema.getInstance().getTableInfoParticipant(), participant);

            ParticipantResponseMap mapEntry = new ParticipantResponseMap();
            mapEntry.beforeInsert(user, container.getId());
            mapEntry.setParticipantId(participant.getRowId());
            mapEntry.setGUID(GUID.makeGUID());
            mapEntry = Table.insert(user, MPowerSchema.getInstance().getTableInfoParticipantResponseMap(), mapEntry);

            transaction.commit();
            return mapEntry.getGUID();
        }
    }

    /**
     * Returns the participant identified by the specified token
     */
    public SurveyParticipant getSurveyParticipant(User user, Container container, String token)
    {
        SQLFragment sql = new SQLFragment();

        sql.append("SELECT mp.Container, mp.Created, mp.Modified, mp.RowId, mp.LastName, mp.FirstName, mp.BirthDate FROM ").append(MPowerSchema.getInstance().getTableInfoParticipant(), "mp").
                append(" JOIN ").append(MPowerSchema.getInstance().getTableInfoParticipantResponseMap(), "mrm").append(" ON mp.RowId = mrm.ParticipantId");

        if (MPowerSchema.getInstance().getSqlDialect().isSqlServer())
        {
            // on sql server, entityid is a uniqueidentifier, need to cast to do the varchar compare
            sql.append(" WHERE CAST((mrm.GUID) AS NVARCHAR(36)) = ?");
        }
        else
        {
            sql.append(" WHERE mrm.GUID = ?");
        }
        sql.add(token);

        SurveyParticipant participant = new SqlSelector(MPowerSchema.getInstance().getSchema().getScope(), sql).getObject(SurveyParticipant.class);
        return participant;
    }

    @Nullable
    public RemoteConnectionInfo getRemoteConnectionInfo(Container c)
    {
        // Check that an entry for the remote connection name exists
        String connectionName = RemoteConnections.REMOTE_QUERY_CONNECTIONS_CATEGORY + ":" + REMOTE_SOURCE_NAME;
        Map<String, String> connectionMap = PropertyManager.getEncryptedStore().getProperties(c, RemoteConnections.REMOTE_QUERY_CONNECTIONS_CATEGORY);
        if (connectionMap.get(connectionName) == null)
        {
            _log.error("The remote connection " + REMOTE_SOURCE_NAME + " has not yet been setup in the remote connection manager.  You may configure a new remote connection through the schema browser.");
            return null;
        }

        // Extract the username, password, and container from the secure property store
        Map<String, String> singleConnectionMap = PropertyManager.getEncryptedStore().getProperties(c, connectionName);
        String url = singleConnectionMap.get(RemoteConnections.FIELD_URL);
        String user = singleConnectionMap.get(RemoteConnections.FIELD_USER);
        String password = singleConnectionMap.get(RemoteConnections.FIELD_PASSWORD);
        String container = singleConnectionMap.get(RemoteConnections.FIELD_CONTAINER);
        if (url == null || user == null || password == null || container == null)
        {
            _log.error("Invalid login credentials in the secure user store");
            return null;
        }

        return new RemoteConnectionInfo(url, user, password, container);
    }

    public static class RemoteConnectionInfo
    {
        private String _url;
        private String _user;
        private String _password;
        private String _container;

        public RemoteConnectionInfo(String url, String user, String password, String container)
        {
            _url = url;
            _user = user;
            _password = password;
            _container = container;
        }

        public String getUrl()
        {
            return _url;
        }

        public String getUser()
        {
            return _user;
        }

        public String getPassword()
        {
            return _password;
        }

        public String getContainer()
        {
            return _container;
        }
    }


    public PatientDemographics createPatientDemographics(SurveyResponseForm form)
    {
        PatientDemographics patientDemographics = PATIENT_DEMOGRAPHICS_FACTORY.fromMap(form.getResponses());
        patientDemographics.setPatientId(form.getToken());

        return patientDemographics;
    }

    public ClinicalDiagnosis createClinicalDiagnosis(SurveyResponseForm form)
    {
        ClinicalDiagnosis clinicalDiagnosis = CLINICAL_DIAGNOSIS_FACTORY.fromMap(form.getResponses());
        clinicalDiagnosis.setPatientId(form.getToken());

        return clinicalDiagnosis;
    }

    public Treatment createTreatment(SurveyResponseForm form)
    {
        Treatment treatment = TREATMENT_FACTORY.fromMap(form.getResponses());
        treatment.setPatientId(form.getToken());

        return treatment;
    }

    public Lifestyle createLifestyle(SurveyResponseForm form)
    {
        Lifestyle lifestyle = LIFE_STYLE_FACTORY.fromMap(form.getResponses());
        lifestyle.setPatientId(form.getToken());

        return lifestyle;
    }

    public LifeQuality createLifequality(SurveyResponseForm form)
    {
        LifeQuality lifequality = LIFE_QUALITY_FACTORY.fromMap(form.getResponses());
        lifequality.setPatientId(form.getToken());

        return lifequality;
    }

    public ActivityTracker createActivityTracker(SurveyResponseForm form)
    {
        ActivityTracker activityTracker = ACTIVITY_TRACKER_FACTORY.fromMap(form.getResponses());
        activityTracker.setPatientId(form.getToken());

        return activityTracker;
    }

    public PatientDemographics savePatientDemographics(User user, Container container, PatientDemographics demographics)
    {
        demographics.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoPatientDemographics(), demographics);
    }

    public Insurance savePatientInsurance(User user, Container container, Insurance insurance)
    {
        insurance.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoInsurance(), insurance);
    }

    public ClinicalDiagnosis saveClinicalDiagnosis(User user, Container container, ClinicalDiagnosis clinicalDiagnosis)
    {
        clinicalDiagnosis.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoClinicalDiagnosis(), clinicalDiagnosis);
    }

    public FamilyHistory saveFamilyHistory(User user, Container container, FamilyHistory history)
    {
        history.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoFamilyHistory(), history);
    }

    public Treatment saveTreatement(User user, Container container, Treatment treatment)
    {
        treatment.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoTreatment(), treatment);
    }

    public TreatmentType saveTreatementType(User user, Container container, TreatmentType treatmentType)
    {
        treatmentType.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoTreatmentType(), treatmentType);
    }

    public LifeQuality saveLifeQuality(User user, Container container, LifeQuality lifeQuality)
    {
        lifeQuality.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoLifeQuality(), lifeQuality);
    }

    public Lifestyle saveLifeStyle(User user, Container container, Lifestyle lifestyle)
    {
        lifestyle.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoLifeStyle(), lifestyle);
    }

    public MedicalCondition saveMedicalCondition(User user, Container container, MedicalCondition medicalCondition)
    {
        medicalCondition.beforeInsert(user, container.getId());
        return Table.insert(user, MPowerSchema.getInstance().getTableInfoMedicalCondition(), medicalCondition);
    }

    public SQLFragment getParticipantResponseMapDeleteSQL(Container container)
    {
        SQLFragment deleteSQL = new SQLFragment("DELETE FROM ").append(MPowerSchema.getInstance().getTableInfoParticipantResponseMap(), "").
                append(" WHERE ParticipantId IN (SELECT RowId FROM ").append(MPowerSchema.getInstance().getTableInfoParticipant(), "").
                append(" WHERE Container = ?)");

        deleteSQL.add(container.getId());

        return deleteSQL;
    }

    public boolean saveActivityTracker(User user, Container container, ActivityTracker activityTracker)
    {
        if (activityTracker.isDirty())
        {
            if (Encryption.isMasterEncryptionPassPhraseSpecified())
            {
                PropertyManager.PropertyMap map = PropertyManager.getEncryptedStore().getWritableProperties(container, MPOWER_ACTIVITY_TRACKER_PROPERTIES, true);

                if (activityTracker.getFitbitUserName() != null && activityTracker.getFitbitPassword() != null)
                {
                    map.put(encode(activityTracker.getPatientId(), "fitbitUserName"), activityTracker.getFitbitUserName());
                    map.put(encode(activityTracker.getPatientId(), "fitbitPassword"), activityTracker.getFitbitPassword());
                }

                if (activityTracker.getJawboneUserName() != null && activityTracker.getJawbonePassword() != null)
                {
                    map.put(encode(activityTracker.getPatientId(), "jawboneUserName"), activityTracker.getJawboneUserName());
                    map.put(encode(activityTracker.getPatientId(), "jawbonePassword"), activityTracker.getJawbonePassword());
                }
                map.save();
                return true;
            }
            else
            {
                throw new IllegalStateException("MasterEncryptionKey has not been specified in " + AppProps.getInstance().getWebappConfigurationFilename());
            }
        }
        return false;
    }

    private String encode(String participantId, String fieldName)
    {
        return participantId + "$" + fieldName;
    }
}