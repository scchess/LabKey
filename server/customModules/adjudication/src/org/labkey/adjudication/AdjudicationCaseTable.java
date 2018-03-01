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
package org.labkey.adjudication;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.security.SecurityPolicyManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.util.StringExpressionFactory;
import org.labkey.api.view.ActionURL;

public class AdjudicationCaseTable extends DefaultAdjudicationTable
{
    public AdjudicationCaseTable(TableInfo table, @NotNull AdjudicationUserSchema userSchema)
    {
        super(table, userSchema);
        wrapAllColumns(true);

        if (SecurityPolicyManager.getPolicy(userSchema.getContainer()).hasPermission(userSchema.getUser(), AdminPermission.class))
        {
            // for admin users create new column that shows the reminder link if the case is still active
            SQLFragment emailReminderSql = new SQLFragment();
            emailReminderSql.append("(SELECT CASE WHEN st.Status = 'Active Adjudication' THEN 'Send Email Reminder' ELSE null END FROM ");
            emailReminderSql.append(AdjudicationSchema.getInstance().getTableInfoAdjudicationCase(), "ac LEFT OUTER JOIN ");
            emailReminderSql.append(AdjudicationSchema.getInstance().getTableInfoStatus(), "st ON st.RowId = ac.StatusId");
            emailReminderSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".CaseId = ac.CaseId)");
            ExprColumn emailReminder = new ExprColumn(this, "Reminders", emailReminderSql, JdbcType.INTEGER);
            emailReminder.setHidden(false);
            ActionURL url = new ActionURL(AdjudicationController.EmailReminderAction.class, getContainer());
            emailReminder.setURL(StringExpressionFactory.create(url.getLocalURIString() + "&caseId=${caseId}"));
            emailReminder.setURLCls("labkey-button");
            emailReminder.setTextAlign("center");
            addColumn(emailReminder);
        }
    }

    @Override
    public ActionURL getInsertURL(Container container)
    {
        return AbstractTableInfo.LINK_DISABLER_ACTION_URL;
    }

    @Override
    public ActionURL getImportDataURL(Container container)
    {
        return AbstractTableInfo.LINK_DISABLER_ACTION_URL;
    }
}
