package org.labkey.cnprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by Binal on 7/19/2017.
 */
public class ActiveFlagsDemographicsProvider extends AbstractListDemographicsProvider
{
    public ActiveFlagsDemographicsProvider(Module module)
    {
        super(module, "study", "activeFlagsSeparated", "activeFlagsSeparated");
    }

    @Override
    public String getName()
    {
        return "Most Recent Census Flags";
    }

    @Override
    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("lsid"));
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("Value"));
        keys.add(FieldKey.fromString("Title"));
        keys.add(FieldKey.fromString("publicdata"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "flags".equalsIgnoreCase(query));
    }
}