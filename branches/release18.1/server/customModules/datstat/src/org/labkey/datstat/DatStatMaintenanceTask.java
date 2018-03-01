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
package org.labkey.datstat;

import org.apache.log4j.Logger;
import org.labkey.api.admin.ImportException;
import org.labkey.api.collections.ConcurrentHashSet;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineService;
import org.labkey.api.security.Encryption;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.settings.AppProps;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyReloadSource;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.ExceptionUtil;
import org.labkey.api.util.SystemMaintenance.MaintenanceTask;

import java.util.Date;
import java.util.Map;
import java.util.Set;

/**
 * Created by klum on 2/19/2015.
 */
public class DatStatMaintenanceTask implements MaintenanceTask
{
    private static Set<String> _datStatContainerIds = new ConcurrentHashSet<>();
    private static final String DATSTAT_STATIC_TASK_PROPERTIES = "DatStatStaticTaskSettings";

    static
    {
        Map<String, String> map = PropertyManager.getProperties(ContainerManager.getRoot(), DATSTAT_STATIC_TASK_PROPERTIES);
        for (String containerId : map.keySet())
            _datStatContainerIds.add(containerId);
    }

    public void run(Logger log)
    {
        long msStart = System.currentTimeMillis();
        log.info("DATStat Import Task starting cycle...");

        for (String containerId : _datStatContainerIds)
        {
            try
            {
                Container container = ContainerManager.getForId(containerId);

                if (null == container)
                {
                    // Container must have been deleted
                    throw new ImportException("Container " + containerId + " does not exist");
                }

                Study study = StudyService.get().getStudy(container);
                if (null == study)
                {
                    // Study must have been deleted
                    throw new ImportException("Study does not exist in folder " + container.getPath());
                }

                if (Encryption.isMasterEncryptionPassPhraseSpecified())
                {
                    Map<String, String> map = PropertyManager.getEncryptedStore().getProperties(container, DatStatManager.DATSTAT_PROPERTIES);

                    if (map.containsKey(DatStatManager.DatStatSettings.Options.enableReload.name()) && Boolean.parseBoolean(map.get(DatStatManager.DatStatSettings.Options.enableReload.name())))
                    {
                        int dayInterval = map.containsKey(DatStatManager.DatStatSettings.Options.reloadInterval.name()) ? Integer.parseInt(map.get(DatStatManager.DatStatSettings.Options.reloadInterval.name())) : 1;
                        Date today = DateUtil.getDateOnly(new Date());
                        Date reloadDate = map.containsKey(DatStatManager.DatStatSettings.Options.reloadDate.name()) ? DateUtil.getDateOnly(new Date(DateUtil.parseDateTime(container, map.get(DatStatManager.DatStatSettings.Options.reloadDate.name())))) : today;

                        if ((today.getTime() - reloadDate.getTime()) % dayInterval == 0)
                        {
                            try
                            {
                                String user = map.get(DatStatManager.DatStatSettings.Options.reloadUser.name());
                                if (user != null)
                                {
                                    int userId = Integer.parseInt(user);
                                    User reloadUser = UserManager.getUser(userId);

                                    if (reloadUser != null)
                                    {
                                        StudyReloadSource reloadSource = StudyService.get().getStudyReloadSource(DatStatReloadSource.NAME);

                                        PipelineJob job = StudyService.get().createReloadSourceJob(container, reloadUser, reloadSource, null);
                                        PipelineService.get().queueJob(job);
                                    }
                                    else
                                        log.error("The specified reload user is invalid");
                                }
                                else
                                    log.error("No reload user has been configured");
                            }
                            catch (Exception e)
                            {
                                log.error("An error occurred exporting from DATStat", e);
                            }
                        }
                    }
                }
                else
                {
                    throw new ImportException("Unable to save or retrieve configuration information. MasterEncryptionKey has not been specified in " + AppProps.getInstance().getWebappConfigurationFilename() + ".");
                }
            }
            catch (ImportException e)
            {
                Container c = ContainerManager.getForId(containerId);
                String message = null != c ? " in folder " + c.getPath() : "";

                log.error("DATStat import failed" + message);
            }
            catch (Throwable t)
            {
                // Throwing from run() will kill the reload task, suppressing all future attempts; log to mothership and continue, so we retry later.
                ExceptionUtil.logExceptionToMothership(null, t);
            }
        }

        log.info("DATStat Import Task finished cycle in " + String.valueOf((System.currentTimeMillis() - msStart) / 1000) + " seconds.");
    }

    public String getDescription()
    {
        return "DATStat Import Task";
    }

    @Override
    public String getName()
    {
        return "DATStatImport";
    }

    @Override
    public boolean canDisable()
    {
        return false;
    }

    @Override
    public boolean hideFromAdminPage() { return true; }

    public static void addDatStatContainer(String containerId)
    {
        _datStatContainerIds.add(containerId);
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(ContainerManager.getRoot(), DATSTAT_STATIC_TASK_PROPERTIES, true);
        map.put(containerId, "true");
        map.save();
    }

    public static void removeDatStatContainer(String containerId)
    {
        _datStatContainerIds.remove(containerId);
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(ContainerManager.getRoot(), DATSTAT_STATIC_TASK_PROPERTIES, true);
        map.remove(containerId);
        map.save();
    }
}
