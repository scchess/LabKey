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
import org.labkey.api.data.AbstractFileDisplayColumn;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.ContainerForeignKey;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.UserIdForeignKey;
import org.labkey.api.util.StringExpressionFactory;
import org.labkey.api.view.ActionURL;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.sql.SQLException;

/**
 * Created by klum on 6/15/2017.
 */
public class CaseDocumentsTable extends FilteredTable<AdjudicationUserSchema>
{
    public CaseDocumentsTable(TableInfo table, @NotNull AdjudicationUserSchema userSchema)
    {
        super(table, userSchema);
        setTitle("Case Documents");
        setDescription("All uploaded case file documents");

        wrapAllColumns(true);

        ColumnInfo rowIdCol = getColumn("RowId");
        rowIdCol.setHidden(true);

        ColumnInfo containerCol = getColumn("Container");
        ContainerForeignKey.initColumn(containerCol, userSchema);

        ColumnInfo createdByCol = getColumn("CreatedBy");
        UserIdForeignKey.initColumn(createdByCol);

        ColumnInfo modifiedByCol = getColumn("ModifiedBy");
        UserIdForeignKey.initColumn(modifiedByCol);

        ColumnInfo documentNameCol = getColumn("DocumentName");
        documentNameCol.setLabel("Case Document");
        ActionURL url = new ActionURL(AdjudicationController.DownloadCaseDocumentAction.class, userSchema.getContainer());
        documentNameCol.setURL(StringExpressionFactory.create(url.getLocalURIString() + "&rowId=${rowId}"));
        documentNameCol.setDisplayColumnFactory(CaseDocumentDisplayColumn::new);

        ColumnInfo documentCol = getColumn("Document");
        documentCol.setHidden(true);
    }


    public static class CaseDocumentDisplayColumn extends AbstractFileDisplayColumn
    {
         public CaseDocumentDisplayColumn(ColumnInfo col)
        {
            super(col);
        }

        @Override
        protected String getFileName(Object value)
        {
            return String.valueOf(value);
        }

        @Override
        protected InputStream getFileContents(RenderContext ctx, Object value) throws FileNotFoundException
        {
            try
            {
                return ctx.getResults().getBinaryStream(FieldKey.fromParts("Document"));
            }
            catch (SQLException e)
            {
                throw new RuntimeException(e);
            }
        }
    }
}
