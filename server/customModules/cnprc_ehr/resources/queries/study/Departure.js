require("ehr/triggers").initScript(this);

function onInit(event, helper){
    helper.setScriptOptions({
        requiresStatusRecalc: true
    });

    helper.decodeExtraContextProperty('departuresInTransaction');

}

EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Departure', function(scriptErrors, helper, row, oldRow) {
    helper.registerDeparture(row.Id, row.date);

    if(helper.isETL())
    {
        //this will close any existing assignments, housing and treatment records
        if(row.nextRelocType != null && row.nextRelocType != 'Here' ) {
            helper.onDeathDeparture(row.Id, row.date);
        }
    }
});