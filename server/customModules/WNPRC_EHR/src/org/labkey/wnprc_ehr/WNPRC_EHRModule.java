/*
 * Copyright (c) 2012-2017 LabKey Corporation
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
package org.labkey.wnprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.resource.Resource;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.wnprc_ehr.buttons.DuplicateTaskButton;
import org.labkey.wnprc_ehr.buttons.WNPRCGoToTaskButton;
import org.labkey.wnprc_ehr.dataentry.Arrival.ArrivalFormType;
import org.labkey.wnprc_ehr.dataentry.Assignment.AssignmentForm;
import org.labkey.wnprc_ehr.dataentry.BehaviorAbstract.BehaviorAbstractForm;
import org.labkey.wnprc_ehr.dataentry.Biopsy.BiopsyForm;
import org.labkey.wnprc_ehr.dataentry.Birth.BirthFormType;
import org.labkey.wnprc_ehr.dataentry.BloodDrawRequest.BloodDrawRequestForm;
import org.labkey.wnprc_ehr.dataentry.BloodDraws.BloodDrawsForm;
import org.labkey.wnprc_ehr.dataentry.Clinpath.ClinpathForm;
import org.labkey.wnprc_ehr.dataentry.ClinpathRequest.ClinpathRequestForm;
import org.labkey.wnprc_ehr.dataentry.Death.DeathForm;
import org.labkey.wnprc_ehr.dataentry.Housing.HousingForm;
import org.labkey.wnprc_ehr.dataentry.HousingRequest.HousingRequestForm;
import org.labkey.wnprc_ehr.dataentry.InRooms.InRoomsForm;
import org.labkey.wnprc_ehr.dataentry.IrregularObservations.IrregularObservationsFormType;
import org.labkey.wnprc_ehr.dataentry.MPR.MPRForm;
import org.labkey.wnprc_ehr.dataentry.Necropsy.NecropsyForm;
import org.labkey.wnprc_ehr.dataentry.PhysicalExamNWM.PhysicalExamNWMForm;
import org.labkey.wnprc_ehr.dataentry.PhysicalExamOWM.PhysicalExamOWMForm;
import org.labkey.wnprc_ehr.dataentry.ProblemList.ProblemListForm;
import org.labkey.wnprc_ehr.dataentry.ProcedureRequest.ProcedureRequestForm;
import org.labkey.wnprc_ehr.dataentry.Surgery.SurgeryForm;
import org.labkey.wnprc_ehr.dataentry.TBTests.TBTestsForm;
import org.labkey.wnprc_ehr.dataentry.TreatmentOrders.TreatmentOrdersForm;
import org.labkey.wnprc_ehr.dataentry.Treatments.TreatmentsForm;
import org.labkey.wnprc_ehr.dataentry.Weight.WeightForm;
import org.labkey.wnprc_ehr.demographics.MostRecentObsDemographicsProvider;
import org.labkey.wnprc_ehr.history.DefaultAlopeciaDataSource;
import org.labkey.wnprc_ehr.history.DefaultBodyConditionDataSource;
import org.labkey.wnprc_ehr.history.DefaultTBDataSource;
import org.labkey.wnprc_ehr.history.WNPRCUrinalysisLabworkType;
import org.labkey.wnprc_ehr.table.WNPRC_EHRCustomizer;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/**
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:52 PM
 */
public class WNPRC_EHRModule extends ExtendedSimpleModule
{
    public static final String NAME = "WNPRC_EHR";
    public static final String CONTROLLER_NAME = "wnprc_ehr";

    public String getName()
    {
        return NAME;
    }

    public double getVersion()
    {
        return 15.30;
    }

    public boolean hasScripts()
    {
        return false;
    }

    protected void init()
    {
        addController(CONTROLLER_NAME, WNPRC_EHRController.class);
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        EHRService.get().registerModule(this);
        EHRService.get().registerTableCustomizer(this, WNPRC_EHRCustomizer.class);
        Resource r = getModuleResource("/scripts/wnprc_ehr/wnprc_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("wnprc_ehr/wnprcOverRides.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("wnprc_ehr/wnprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("wnprc_ehr/datasetButtons.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("wnprc_ehr/animalPortal.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("wnprc_ehr/Inroom.js"), this);

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "List Single-housed Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Single%20Housed"), "Commonly Used Queries");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "View Roommate History for Animals", this, DetailsURL.fromString("/ehr/animalHistory.view#inputType:singleSubject&activeReport:roommateHistory"), "Commonly Used Queries");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "Find Animals Housed In A Given Room/Cage At A Specific Time", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Commonly Used Queries");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Living Center Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Alive%2C at Center"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Center Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Assigned To Breeding", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.Id/activeAssignments/availability~contains=b"), "Browse Animals");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Living Center Macaques Plus MHC Typing", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Living Rhesus Plus MHC Typing"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Living With SIV", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Living With SIV"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "MHC SSP Data", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=SSP_Pivot"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Single Housed Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Single Housed"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "TB: Untested In Past 4 months", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=TB Older Than 4 Months"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Unassigned Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Unassigned%20Animals"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Unassigned Rhesus Plus MHC Typing", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Unassigned%20Rhesus%20With%20MHC%20Typing"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Unweighed In Past 45 Days", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Unweighed%20Over%2045%20Days"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "List Most Recent Body Condition Code For Each Animal in the Colony", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Current Colony Condition"), "Browse Animals");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Population Summary By Species, Gender and Age", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=colonyPopulationByAge"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Find Animals Housed At The Center Over A Date Range", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "List Singly-Housed Animals At The Center On A Given Date", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=SinglyHousedAnimals"), "Other Searches");

        EHRService.get().registerDemographicsProvider(new MostRecentObsDemographicsProvider(this));

        //buttons
        EHRService.get().registerMoreActionsButton(new WNPRCGoToTaskButton(this, "Assignment"), "study", "assignment");
        EHRService.get().registerMoreActionsButton(new WNPRCGoToTaskButton(this, "Feeding"), "study", "feeding");
        EHRService.get().registerMoreActionsButton(new DuplicateTaskButton(this), "ehr", "Tasks_DataEntry");
        EHRService.get().registerMoreActionsButton(new DuplicateTaskButton(this), "ehr", "my_tasks");
        EHRService.get().registerMoreActionsButton(new MarkCompletedButton(this, "study", "assignment", "End Assignments"), "study", "assignment");

        EHRService.get().registerOptionalClinicalHistoryResources(this);
        EHRService.get().registerHistoryDataSource(new DefaultAlopeciaDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultBodyConditionDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultTBDataSource(this));

        EHRService.get().addModuleRequiringLegacyExt3EditUI(this);

        EHRService.get().registerLabworkType(new WNPRCUrinalysisLabworkType(this));

        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( IrregularObservationsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( ArrivalFormType.class,               this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( BirthFormType.class,                 this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( BloodDrawRequestForm.class,          this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( BloodDrawsForm.class,                this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( ClinpathForm.class,                  this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory( ClinpathRequestForm.class,           this));

        // Register all of the data entry forms.
        List<Class> forms = Arrays.asList(
                ArrivalFormType.class,
                AssignmentForm.class,
                BehaviorAbstractForm.class,
                BirthFormType.class,
                BiopsyForm.class,
                BloodDrawRequestForm.class,
                BloodDrawsForm.class,
                ClinpathForm.class,
                ClinpathRequestForm.class,
                DeathForm.class,
                HousingForm.class,
                HousingRequestForm.class,
                InRoomsForm.class,
                IrregularObservationsFormType.class,
                MPRForm.class,
                NecropsyForm.class,
                PhysicalExamNWMForm.class,
                PhysicalExamOWMForm.class,
                ProblemListForm.class,
                ProcedureRequestForm.class,
                SurgeryForm.class,
                TBTestsForm.class,
                TreatmentOrdersForm.class,
                TreatmentsForm.class,
                WeightForm.class
        );
        for(Class form : forms) {
            EHRService.get().registerFormType(new DefaultDataEntryFormFactory(form, this));
        }
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return Collections.emptySet();
    }
}
