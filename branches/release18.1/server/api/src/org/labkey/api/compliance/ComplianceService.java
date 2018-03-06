/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.labkey.api.compliance;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Activity;
import org.labkey.api.data.Container;
import org.labkey.api.data.PHI;
import org.labkey.api.query.QueryAction;
import org.labkey.api.security.User;
import org.labkey.api.services.ServiceRegistry;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.ViewContext;

/**
 * Created by davebradlee on 7/27/17.
 *
 */
public interface ComplianceService
{
    static @NotNull ComplianceService get()
    {
        // Return default service if module not registered
        ComplianceService service = ServiceRegistry.get(ComplianceService.class);
        if (null == service)
            service = new DefaultComplianceService();
        return service;
    }

    static void setInstance(ComplianceService instance)
    {
        ServiceRegistry.get().registerService(ComplianceService.class, instance);
    }

    default ActionURL urlFor(Container container, QueryAction action, ActionURL queryBasedUrl)
    {
        return null;
    }

    default boolean hasElecSignPermission(@NotNull Container container, @NotNull User user)
    {
        return false;
    }

    default boolean hasViewSignedSnapshotsPermission(@NotNull Container container, @NotNull User user)
    {
        return false;
    }

    default @NotNull PHI getMaxAllowedPhi(@NotNull Container container, @NotNull User user)
    {
        return PHI.Restricted;
    }
    default Activity getCurrentActivity(ViewContext viewContext)
    {
        return null;
    }
    default String getPHIBanner(ViewContext viewContext)
    {
        return null;
    }

    class DefaultComplianceService implements ComplianceService
    {
    }
}
