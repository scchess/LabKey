/*
 * Copyright (c) 2016 LabKey Corporation
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
package org.labkey.janssenreports;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.RenderContext;
import org.labkey.api.query.FieldKey;

import java.util.Set;

/**
 * Created by: jeckels
 * Date: 2/21/16
 */
public class ResidueDisplayColumnFactory implements DisplayColumnFactory
{
    @Override
    public DisplayColumn createRenderer(ColumnInfo colInfo)
    {
        return new ResidueDisplayColumn(colInfo);
    }

    private static class ResidueDisplayColumn extends DataColumn
    {
        private final FieldKey _unmodifiedFieldKey;
        private final FieldKey _startIndexFieldKey;

        public ResidueDisplayColumn(ColumnInfo columnInfo)
        {
            super(columnInfo);
            _unmodifiedFieldKey = new FieldKey(getBoundColumn().getFieldKey().getParent(), "UnmodifiedSequence");
            _startIndexFieldKey = new FieldKey(getBoundColumn().getFieldKey().getParent(), "StartIndex");
        }

        @Override
        public boolean isFilterable()
        {
            return false;
        }

        @Override
        public boolean isSortable()
        {
            return false;
        }

        @Override
        @NotNull
        public Object getValue(RenderContext ctx)
        {
            Integer startIndex = ctx.get(_startIndexFieldKey, Integer.class);
            String unmodifiedSequence = ctx.get(_unmodifiedFieldKey, String.class);
            String modifiedSequence = ctx.get(getBoundColumn().getFieldKey(), String.class);

            assert unmodifiedSequence.length() < modifiedSequence.length() : "Unmodified is not shorter than modified: " + unmodifiedSequence + " vs " + modifiedSequence;

            int offset = 0;

            for (int i = 1; i < unmodifiedSequence.length(); i++)
            {
                boolean isAA = Character.isLetter(unmodifiedSequence.charAt(i));
                if (isAA)
                {
                    offset++;
                }
                if (unmodifiedSequence.charAt(i) != modifiedSequence.charAt(i))
                {
                    return Character.toString(modifiedSequence.charAt(i - 1)) + (startIndex.intValue() + offset);
                }
            }
            return "Error - unable to calculate residue!";
        }

        @Override
        public Object getDisplayValue(RenderContext ctx)
        {
            return getValue(ctx);
        }

        @NotNull
        @Override
        public String getFormattedValue(RenderContext ctx)
        {
            return getValue(ctx).toString();
        }

        @Override
        public void addQueryFieldKeys(Set<FieldKey> keys)
        {
            super.addQueryFieldKeys(keys);
            keys.add(_unmodifiedFieldKey);
            keys.add(_startIndexFieldKey);
        }
    }
}
