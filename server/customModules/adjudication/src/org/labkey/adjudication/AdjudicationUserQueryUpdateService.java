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
package org.labkey.adjudication;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.adjudication.security.AdjudicationDataReviewerRole;
import org.labkey.adjudication.security.AdjudicationInfectionMonitorRole;
import org.labkey.adjudication.security.AdjudicationLabPersonnelRole;
import org.labkey.adjudication.security.AdjudicatorRole;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.MutableSecurityPolicy;
import org.labkey.api.security.RoleAssignment;
import org.labkey.api.security.SecurityPolicy;
import org.labkey.api.security.SecurityPolicyManager;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.roles.Role;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by davebradlee on 11/22/15
 */
public class AdjudicationUserQueryUpdateService extends DefaultQueryUpdateService
{
    public AdjudicationUserQueryUpdateService(TableInfo queryTable, TableInfo dbTable)
    {
        super(queryTable, dbTable);
    }

    @Override
    public List<Map<String, Object>> insertRows(User user, Container container, List<Map<String, Object>> rows,
                                                BatchValidationException errors, @Nullable Map<Enum, Object> configParameters,
                                                Map<String, Object> extraScriptContext)
                                                throws DuplicateKeyException, QueryUpdateServiceException, SQLException
    {
        try (DbScope.Transaction transaction = getDbTable().getSchema().getScope().ensureTransaction())
        {
            // Check for duplicates ahead of time
            Map<Integer, Map<String, Object>> userIdToOldRow = getUserToRowMap(container);
            rows.forEach((row) ->
            {
                if (userIdToOldRow.containsKey(row.get(AdjudicationUserTable.USERID)))
                    errors.addRowError(new ValidationException("User already has a role in this container."));
            });

            if (!errors.hasErrors())
            {
                List<Map<String, Object>> resultRows = super.insertRows(user, container, rows, errors, configParameters, extraScriptContext);
                if (!errors.hasErrors())
                {
                    List<UserRoleChange> roleAdditions = new ArrayList<>();
                    resultRows.forEach((row) ->
                    {
                        if (null != row && null != row.get(AdjudicationUserTable.USERID) && isAdjudicationRole(row))
                        {
                            roleAdditions.add(makeRoleChange(row));
                        }
                    });
                    updateContainerSecurityPolicy(user, container, Collections.emptyList(), roleAdditions);
                    transaction.commit();
                    return resultRows;
                }
            }
        }
        return Collections.emptyList();
    }

    @Override
    public List<Map<String, Object>> updateRows(User user, Container container, List<Map<String, Object>> rows,
                                                List<Map<String, Object>> oldKeys, @Nullable Map<Enum, Object> configParameters,
                                                Map<String, Object> extraScriptContext)
                                                throws InvalidKeyException, BatchValidationException, QueryUpdateServiceException, SQLException
    {
        try (DbScope.Transaction transaction = getDbTable().getSchema().getScope().ensureTransaction())
        {
            Map<Integer, Map<String, Object>> userIdToOldRow = getUserToRowMap(container);

            List<Map<String, Object>> resultRows = super.updateRows(user, container, rows, oldKeys, configParameters, extraScriptContext);

            List<UserRoleChange> roleAdditions = new ArrayList<>();
            List<UserRoleChange> roleRemovals = new ArrayList<>();
            for (Map<String, Object> row : resultRows)
            {
                Map<String, Object> oldRow = userIdToOldRow.get(row.get(AdjudicationUserTable.USERID));
                if (null != oldRow && (int)oldRow.get(AdjudicationUserTable.ROLEID) != (int)row.get(AdjudicationUserTable.ROLEID))
                {
                    if (isAdjudicatorRole(oldRow))
                    {
                        AdjudicationManager.get().removeAdjudicatorTeamMember(container, (Integer)oldRow.get("RowId"));
                    }

                    if (isAdjudicationRole(oldRow))
                    {
                        roleRemovals.add(makeRoleChange(oldRow));
                    }

                    if (isAdjudicationRole(row))
                    {
                        roleAdditions.add(makeRoleChange(row));
                    }
                }
            }

            updateContainerSecurityPolicy(user, container, roleRemovals, roleAdditions);
            transaction.commit();
            return resultRows;
        }
    }

    @Override
    public List<Map<String, Object>> deleteRows(User user, Container container, List<Map<String, Object>> keys,
                                                @Nullable Map<Enum, Object> configParameters,
                                                @Nullable Map<String, Object> extraScriptContext)
                                                throws InvalidKeyException, BatchValidationException, QueryUpdateServiceException, SQLException
    {
        try (DbScope.Transaction transaction = getDbTable().getSchema().getScope().ensureTransaction())
        {
            // remove any rows in the team user table for the given adjudication user RowId
            for (Map<String, Object> key : keys)
            {
                AdjudicationManager.get().removeAdjudicatorTeamMember(container, (Integer)key.get("RowId"));
            }

            List<UserRoleChange> roleRemovals = new ArrayList<>();
            for (Map<String, Object> key : keys)
            {
                Map<String, Object> oldRow = getRow(user, container, key);
                if (null != oldRow && isAdjudicationRole(oldRow))
                {
                    roleRemovals.add(makeRoleChange(oldRow));
                }
            }
            
            List<Map<String, Object>> resultRows = super.deleteRows(user, container, keys, configParameters, extraScriptContext);

            // No need to validate deletes

            updateContainerSecurityPolicy(user, container, roleRemovals, Collections.emptyList());
            
            transaction.commit();
            return resultRows;
        }
    }

    protected static class UserRoleChange
    {
        private final int _userid;
        private final Class<? extends Role> _roleClass;

        public UserRoleChange(int userId, @NotNull Class<? extends Role> roleClass)
        {
            _userid = userId;
            _roleClass = roleClass;
        }

        public int getUserId()
        {
            return _userid;
        }

        public Class<? extends Role> getRoleClass()
        {
            return _roleClass;
        }
    }

    protected void updateContainerSecurityPolicy(User user, Container container, List<UserRoleChange> roleRemovals, List<UserRoleChange> roleAdditions)
    {
        if (!SecurityPolicyManager.getPolicy(container).hasPermission(user, AdminPermission.class))
            throw new IllegalArgumentException("You do not have permission to modify the security policy for this resource!");

        //get the existing policy so we can audit how it's changed
        SecurityPolicy oldPolicy = SecurityPolicyManager.getPolicy(container);
        MutableSecurityPolicy newPolicy = new MutableSecurityPolicy(container);

        for (RoleAssignment roleAssignment : oldPolicy.getAssignments())
        {
            boolean removeRoleAssignment = false;
            for (UserRoleChange userRoleChange : roleRemovals)
            {
                if (roleAssignment.getUserId() == userRoleChange.getUserId() &&
                    roleAssignment.getRole().getClass().getName().equals(userRoleChange.getRoleClass().getName()))
                {
                    removeRoleAssignment = true;   // remove this role assignment
                    break;
                }
            }

            if (!removeRoleAssignment)
            {
                User roleUser = UserManager.getUser(roleAssignment.getUserId());
                if (null != roleUser)
                    newPolicy.addRoleAssignment(roleUser, roleAssignment.getRole());
            }
        }

        for (UserRoleChange roleChange : roleAdditions)
        {
            User roleUser = UserManager.getUser(roleChange.getUserId());
            if (null != roleUser)
                newPolicy.addRoleAssignment(roleUser, roleChange.getRoleClass());
        }

        SecurityPolicyManager.savePolicy(newPolicy);
    }

    private boolean checkRole(Map<String, Object> row, String roleName)
    {
        return (int)row.get(AdjudicationUserTable.ROLEID) == AdjudicationUserTable.getAdjudicationRole(roleName);
    }

    private boolean isAdjudicationRole(Map<String, Object> row)
    {
        return !checkRole(row, AdjudicationUserTable.FOLDERADMIN) && !checkRole(row, AdjudicationUserTable.TOBENOTIFIED);
    }

    private boolean isAdjudicatorRole(Map<String, Object> row)
    {
        return checkRole(row, AdjudicationUserTable.ADJUDICATOR);
    }

    private UserRoleChange makeRoleChange(Map<String, Object> row)
    {
        Class<? extends Role> roleClass;
        if (checkRole(row, AdjudicationUserTable.LABPERSONNEL))
        {
            roleClass = AdjudicationLabPersonnelRole.class;
        }
        else if (checkRole(row, AdjudicationUserTable.ADJUDICATOR))
        {
            roleClass = AdjudicatorRole.class;
        }
        else if (checkRole(row, AdjudicationUserTable.INFECTIONMONITOR))
        {
            roleClass = AdjudicationInfectionMonitorRole.class;
        }
        else if (checkRole(row, AdjudicationUserTable.DATAREVIEWER))
        {
            roleClass = AdjudicationDataReviewerRole.class;
        }
        else
        {
            throw new IllegalStateException("Table contained unrecognized role.");
        }
        return new UserRoleChange((Integer) row.get(AdjudicationUserTable.USERID), roleClass);
    }

    private Map<Integer, Map<String, Object>> getUserToRowMap(Container container)
    {
        Map<Integer, Map<String, Object>> userIdToRow = new HashMap<>();
        new TableSelector(getDbTable(), SimpleFilter.createContainerFilter(container), null)
                .forEachMap((map) -> userIdToRow.put((Integer) map.get(AdjudicationUserTable.USERID), map));
        return userIdToRow;
    }
}
