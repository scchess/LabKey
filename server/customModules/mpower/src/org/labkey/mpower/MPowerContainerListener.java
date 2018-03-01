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

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager.ContainerListener;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.security.User;
import org.labkey.api.util.ContainerUtil;

import java.beans.PropertyChangeEvent;
import java.util.Collection;
import java.util.Collections;

public class MPowerContainerListener implements ContainerListener
{
    @Override
    public void containerCreated(Container c, User user)
    {
    }

    @Override
    public void containerDeleted(Container c, User user)
    {
        try (DbScope.Transaction transaction = MPowerSchema.getInstance().getSchema().getScope().ensureTransaction())
        {
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoClinicalDiagnosis(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoFamilyHistory(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoInsurance(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoLifeQuality(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoLifeStyle(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoMedicalCondition(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoTreatment(), c, null);
            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoTreatmentType(), c, null);

            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoPatientDemographics(), c, null);
            new SqlExecutor(MPowerSchema.getInstance().getSchema()).execute(MPowerManager.get().getParticipantResponseMapDeleteSQL(c));

            ContainerUtil.purgeTable(MPowerSchema.getInstance().getTableInfoParticipant(), c, null);

            transaction.commit();
        }

    }

    @Override
    public void propertyChange(PropertyChangeEvent evt)
    {
    }

    @Override
    public void containerMoved(Container c, Container oldParent, User user)
    {
    }

    @NotNull @Override
    public Collection<String> canMove(Container c, Container newParent, User user)
    {
        return Collections.emptyList();
    }
}