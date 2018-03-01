package org.labkey.adjudication.data;

import org.labkey.api.data.Entity;

/**
 * Created by davebradlee on 11/7/17.
 */
public class AssayType extends Entity
{
    private int _rowId;
    private String _name;
    private String _label;

    public int getRowId()
    {
        return _rowId;
    }

    public void setRowId(int rowId)
    {
        _rowId = rowId;
    }

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        _name = name;
    }

    public String getLabel()
    {
        return _label;
    }

    public void setLabel(String label)
    {
        _label = label;
    }
}
