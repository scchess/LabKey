package org.labkey.cnprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;

public class MorningHealthSignsDisplayColumnFactory implements DisplayColumnFactory
{
    @Override
    public DisplayColumn createRenderer(ColumnInfo colInfo)
    {
        return new MorningHealthSignsDisplayColumn(colInfo);
    }
}
