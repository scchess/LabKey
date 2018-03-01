package org.labkey.adjudication;

import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.dataiterator.DataIteratorBuilder;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by davebradlee on 11/10/17.
 */
public class AssayTypeTable extends DefaultAdjudicationTable
{
    public AssayTypeTable(TableInfo realTable, AdjudicationUserSchema schema)
    {
        super(realTable, schema, true, false);
        setImportURL(AbstractTableInfo.LINK_DISABLER);
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new DefaultQueryUpdateService(this, this.getRealTable())
        {
            @Override
            public int importRows(User user, Container container, DataIteratorBuilder rows, BatchValidationException errors,
                                  Map<Enum, Object> configParameters, @Nullable Map<String, Object> extraScriptContext) throws SQLException
            {
                throw new UnsupportedOperationException("Import not supported for AssayType table");
            }

            @Override
            public List<Map<String, Object>> insertRows(User user, Container container, List<Map<String, Object>> rows,
                                                        BatchValidationException errors, @Nullable Map<Enum, Object> configParameters,
                                                        Map<String, Object> extraScriptContext)
                    throws DuplicateKeyException, QueryUpdateServiceException, SQLException
            {
                try
                {
                    return super.insertRows(user, container, rows, errors, configParameters, extraScriptContext);
                }
                finally
                {
                    AdjudicationManager.get().clearAssayTypesCache(container);
                }
            }

            @Override
            public List<Map<String, Object>> updateRows(User user, Container container, List<Map<String, Object>> rows,
                                                        List<Map<String, Object>> oldKeys, @Nullable Map<Enum, Object> configParameters,
                                                        Map<String, Object> extraScriptContext)
                    throws InvalidKeyException, BatchValidationException, QueryUpdateServiceException, SQLException
            {
                try
                {
                    return super.updateRows(user, container, rows, oldKeys, configParameters, extraScriptContext);
                }
                finally
                {
                    AdjudicationManager.get().clearAssayTypesCache(container);
                }
            }

            @Override
            public List<Map<String, Object>> deleteRows(User user, Container container, List<Map<String, Object>> keys,
                                                        @Nullable Map<Enum, Object> configParameters, @Nullable Map<String, Object> extraScriptContext)
                    throws InvalidKeyException, BatchValidationException, QueryUpdateServiceException, SQLException
            {
                try
                {
                    return super.deleteRows(user, container, keys, configParameters, extraScriptContext);
                }
                finally
                {
                    AdjudicationManager.get().clearAssayTypesCache(container);
                }
            }
        };
    }
}
