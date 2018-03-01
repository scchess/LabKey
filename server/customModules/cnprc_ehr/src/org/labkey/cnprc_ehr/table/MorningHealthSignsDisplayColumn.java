package org.labkey.cnprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.util.PageFlowUtil;

public class MorningHealthSignsDisplayColumn extends DataColumn
{
    public MorningHealthSignsDisplayColumn(ColumnInfo col)
    {
        super(col);
    }

    @Override
    public String getFormattedValue(RenderContext ctx)
    {
        String observation = (String)ctx.get(getColumnInfo().getFieldKey());
        StringBuilder html = new StringBuilder();
        if ( observation != null && !observation.isEmpty())
        {
            String[] codes = observation.split(",");
            for (int i = 0; i < codes.length; i++)
            {
                String code = PageFlowUtil.filter(codes[i]);
                if (i > 0)
                {
                    html.append(", ");
                }
                html.append("<a href=\"cnprc_ehr-observationCodeDetail.view?obsCode=" + code + "\">" + code + "</a>");
            }
        }
        else
        {
            html.append("&nbsp;");
        }

        return html.toString();
    }
}
