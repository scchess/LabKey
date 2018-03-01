package org.labkey.cnprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by Binal on 7/19/2017.
 */
public class PathologyReportsDemographicsProvider extends AbstractListDemographicsProvider
{
    public PathologyReportsDemographicsProvider(Module module)
    {
        super(module, "study", "pathologyReports", "pathologyReports");
    }

    @Override
    public String getName()
    {
        return "Pathology Reports";
    }

    @Override
    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("lsid"));
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("reportId"));
        keys.add(FieldKey.fromString("datePerformed"));
        keys.add(FieldKey.fromString("project"));
        keys.add(FieldKey.fromString("investigator"));
        keys.add(FieldKey.fromString("dateCompleted"));
        keys.add(FieldKey.fromString("publicdata"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return (("study".equalsIgnoreCase(schema) && "necropsy".equalsIgnoreCase(query))
                || ("study".equalsIgnoreCase(schema) && "biopsy".equalsIgnoreCase(query)));
    }
}