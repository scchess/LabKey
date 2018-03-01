package org.labkey.cnprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by Binal on 7/19/2017.
 */
public class LastProjectsDemographicsProvider extends AbstractListDemographicsProvider
{
    public LastProjectsDemographicsProvider(Module module)
    {
        super(module, "study", "lastAssignments", "lastProjects");
    }

    @Override
    public String getName()
    {
        return "Last Project(s)";
    }

    @Override
    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("projectDate"));
        keys.add(FieldKey.fromString("projectType"));
        keys.add(FieldKey.fromString("projectId"));
        keys.add(FieldKey.fromString("pi"));
        keys.add(FieldKey.fromString("projectName"));
        keys.add(FieldKey.fromString("publicdata"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return (("study".equalsIgnoreCase(schema) && "assignment".equalsIgnoreCase(query)) ||
                ("study".equalsIgnoreCase(schema) && "demographics".equalsIgnoreCase(query)));
    }
}