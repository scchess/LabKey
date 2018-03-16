/*
 * Copyright (c) 2016-2017 LabKey Corporation
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

package org.labkey.test.tests.cnprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SaveRowsResponse;
import org.labkey.remoteapi.query.UpdateRowsCommand;
import org.labkey.test.Locator;
import org.labkey.test.ModulePropertyValue;
import org.labkey.test.SortDirection;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.categories.EHR;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.components.WebPartPanel;
import org.labkey.test.components.ehr.panel.AnimalSearchPanel;
import org.labkey.test.components.ext4.widgets.SearchPanel;
import org.labkey.test.pages.cnprc_ehr.CNPRCAnimalHistoryPage;
import org.labkey.test.pages.ehr.AnimalHistoryPage;
import org.labkey.test.pages.ehr.ColonyOverviewPage;
import org.labkey.test.pages.ehr.EnterDataPage;
import org.labkey.test.tests.ehr.AbstractGenericEHRTest;
import org.labkey.test.util.Crawler.ControllerActionId;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PasswordUtil;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.SchemaHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.external.labModules.LabModuleHelper;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

@Category({CustomModules.class, EHR.class})
public class CNPRC_EHRTest extends AbstractGenericEHRTest implements SqlserverOnlyTest
{
    private static final String PROJECT_NAME = "CNPRC";
    protected static final String UNIT_CODE = "uc101";
    private static final Integer PROJECT_ROW_ID = 123;
    private static final String PROTOCOL_10_CHAR = "Prot10Char" ;
    private static final String PROJECT_CODE_5_CHAR_0 = "Pc5C0" ;
    private static final String PROJECT_CODE_5_CHAR_1 = "Pc5C1" ;
    private static final String PROJECT_CODE_5_CHAR_2 = "Pc5C2" ;
    private static final String PROTOCOL_ID_10_CHAR_1 = "Protocol01";
    private static final String PROTOCOL_ID_10_CHAR_2 = "Protocol02";
    private static final String PROJECT_INVESTIGATOR_NAME_1 = "PI_NAME_1" ;
    private static final String PROJECT_INVESTIGATOR_NAME_2 = "PI_NAME_2" ;
    protected static final String INVES_ID_1 = "1001";
    protected static final String INVES_ID_2 = "1002";
    public static final String SCHEMA_CNPRC_PDL = "cnprc_pdl";
    public static final String SCHEMA_CNPRC_BILLING = "cnprc_billing";
    protected final String ANIMAL_HISTORY_URL = "/ehr/" + PROJECT_NAME + "/animalHistory.view?";
    private static final String FOLDER_NAME = "CNPRC";
    private static final String COREFACILITIES = "Core Facilities";
    private static final String GENETICSFOLDER = "Genetics";
    private static final String PDLFOLDER = "PDL";
    private static final String BILLINGFOLDER = "Billing";
    private static final String COMPLIANCE_AND_TRAINING_FOLDER = "Compliance And Training";
    protected static final String ROOM_AB5001 = "AB5001";
    protected static final String ROOM_AC5003 = "AC5003";
    protected static final String ROOM_AD5003 = "AD5003";
    protected static final String ROOM_3168659 = "3168659";

    public static final String CNPRC_ANIMAL = "TEST3804589";
    private static final String ASSAY_GENETICS = "Genetics";
    private static final File ASSAY_GENETICS_XAR = TestFileUtils.getSampleData("cnprc/assays/CNPRC_Genetics.xar");
    public static final String GENETICS_PANEL_LABEL = "Genetics:";
    private static final File LOOKUP_LIST_ARCHIVE = TestFileUtils.getSampleData("cnprc/lists/CNPRC_PDL.lists.zip");
    private static Integer _pipelineJobCount = 0;

    private static final File IMAGE_TSV = TestFileUtils.getSampleData("cnprc/image/image.tsv");
    private static final File IMAGE_PATHOLOGY_TSV = TestFileUtils.getSampleData("cnprc/image/image_pathology.tsv");
    private static final File IMAGE_SNOMED_TSV = TestFileUtils.getSampleData("cnprc/image/image_snomed.tsv");

    private static final File PDL_ORDER_TSV = TestFileUtils.getSampleData("cnprc/tables/CNPRC_PDL_ORDERS.tsv");
    private static final File PDL_SAMPLE_TSV = TestFileUtils.getSampleData("cnprc/tables/CNPRC_PDL_SAMPLES.tsv");
    private static final File PDL_SUB_TEST_TSV = TestFileUtils.getSampleData("cnprc/tables/CNPRC_PDL_SUB_TESTS.tsv");
    private static final File PDL_TEST_TSV = TestFileUtils.getSampleData("cnprc/tables/CNPRC_PDL_TESTS.tsv");
    private static final File BILLING_ACCOUNT_TSV = TestFileUtils.getSampleData("cnprc/tables/CNPRC_BILLING_ACCOUNTS.tsv");
    private static final File CNPRC_EHR_CONCEPTIONS_TSV = TestFileUtils.getSampleData("cnprc/tables/CNPRC_EHR_CONCEPTIONS.tsv");
    private static final File CNPRC_EHR_CAGE_LOCATION_HISTORY = TestFileUtils.getSampleData("cnprc/tables/CNPRC_EHR_CAGE_LOCATION_HISTORY.tsv");
    private static final File CNPRC_EHR_ROOM_ENCLOSURE = TestFileUtils.getSampleData("cnprc/tables/CNPRC_EHR_ROOM_ENCLOSURE.tsv");
    private static final File CNPRC_EHR_BREEDING_ROSTER = TestFileUtils.getSampleData("cnprc/tables/CNPRC_EHR_BREEDING_ROSTER.tsv");
    private static final File EHR_LOOKUP_VIROLOGY_SAMPLE_TYPE = TestFileUtils.getSampleData("cnprc/tables/EHR_LOOKUP_VIROLOGY_SAMPLE_TYPE.TSV");
    private static final File EHR_LOOKUP_TEST_VIRUS_MAPPING = TestFileUtils.getSampleData("cnprc/tables/EHR_LOOKUP_TEST_VIRUS_MAPPING.TSV");
    private static final File EHR_LOOKUP_TEST_TARGET_MAPPING = TestFileUtils.getSampleData("cnprc/tables/EHR_LOOKUP_TEST_TARGET_MAPPING.TSV");
    private static final File EHR_LOOKUP_TEST_METHOD_MAPPING = TestFileUtils.getSampleData("cnprc/tables/EHR_LOOKUP_TEST_METHOD_MAPPING.TSV");
    private SchemaHelper _schemaHelper = new SchemaHelper(this);

    public static final Map<String, Collection<String>> CNPRC_REPORTS = new TreeMap<String, Collection<String>>()
    {{
        put("Assignments and Groups", Arrays.asList(
                "Assignment History",
                "Per-diem Payor Assignment",
                "Project Assignment History"));
        put("BBA", Arrays.asList(
                "Behavior",
                "Lab Results"));
        put("Behavior", Arrays.asList(
                "Behavior Cases",
                "Behavior Remarks",
                "Behavior Treatments",
                "Enrichment",
                "Foster Infant History",
                "Foster Mother History",
                "Full History",
                "Pairing History",
                "Pairing Observations",
                "Pairing With Housing"
        ));
        put("Clinical", Arrays.asList(
                "Cases",
                "Cases Over 2 Years",
                "Clinical History",
                "Clinical Remarks",
                "Clinical Snapshot",
                "Full History",
                "Full History Plus Obs",
                "Hospital Admission and Discharge",
                "Immunizations",
                "Medication Orders",
                "Observations",
                "Procedures",
                "SNOMED",
                "Tasks"));
        put("Colony Management", Arrays.asList(
                "Behavior Remarks",
                "Birth Records",
                "Cites Review",
                "Death Records",
                "Diet",
                "Feeding",
                "Geriatrics",
                "Housing - Active",
                "Housing History",
                "Menses Calendar",
                "Potential Parents",
                "Weights"));
        put("Daily Reports", Arrays.asList(
                "Active Surgery Cases",
                "Clinical Medication Schedule",
                "Diarrhea",
                "Diarrhea Calendar",
                "Diets",
                "Meds/Diet - Incomplete",
                "Morning Health Signs",
                "Obs/Treatment",
                "Poor Appetite",
                "Surgical Medication Schedule",
                "Today's History",
                "Treatments - Afternoon",
                "Treatments - Evening",
                "Treatments - Master",
                "Treatments - Morning"));
        put("General", Arrays.asList(
                "Active Flags",
                "Arrivals",
                "Charges",
                "Deaths",
                "Demographics",
                "Departures",
                "Extended Abstract",
                "Major Events",
                "Notes",
                "Snapshot",
                "Weight, TB, BCS"));
        put("Genetics", Arrays.asList(
                "Inbreeding Coefficients",
                "Kinship",
                "Parentage",
                "Pedigree"));
        put("Lab Results", Arrays.asList(
                "Antibiotic Sensitivity",
                "Biochemistry",
                "Hematology",
                "iStat",
                "Lab Runs",
                "Microbiology",
                "Misc Tests",
                "Parasitology",
                "TB Test Dates",
                "Urinalysis",
                "Virology"));
        put("Pathology", Arrays.asList(
                "Biopsies",
                "Clinical History - Full",
                "Gross Findings",
                "Histology",
                "Morphologic Diagnosis",
                "Necropsies",
                "SNOMED Codes - Grouped",
                "Tissue Measurements"));
        put("Physical Exam", Arrays.asList(
                "Alopecia",
                "Body Condition",
                "Dental Status",
                "Exams",
                "PE Findings"));
        put("Repository", Arrays.asList(
                "Freezer DB Samples",
                "Pathology Inventory",
                "Serum Bank"));
        put("Reproductive Management", Arrays.asList(
                "Birth Records",
                "Breeding",
                "Breeding Group",
                "Conception History",
                "Cycle",
                "Cycle Length",
                "Mating Success Rates",
                "Matings",
                "Menses",
                "Offspring",
                "Pregnancy Determinations",
                "Reproductive Summary",
                "Semen Analysis",
                "Siblings"));
        put("Respiratory Diseases", Arrays.asList(
                "RD Asthma CBC",
                "RD Skin Sensitization"));
        put("Surgery", Arrays.asList(
                "Procedure Summary",
                "Surgeries",
                "Surgeries Today",
                "Surgery Cases",
                "Surgery Cases Closed Today",
                "Surgery Checklist",
                "Surgical Medication Schedule"));
    }};

    @Override
    protected File getStudyPolicyXML()
    {
        return TestFileUtils.getSampleData("cnprcEHRStudyPolicy.xml");
    }

    @BeforeClass
    public static void setupProject() throws Exception
    {
        CNPRC_EHRTest init = (CNPRC_EHRTest)getCurrentTest();
        init.doSetup();
    }

    private void doSetup() throws Exception
    {
        new RReportHelper(this).ensureRConfig();
        initProject("CNPRC EHR");
        goToProjectHome();
        clickFolder(GENETICSFOLDER);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_GENETICS_XAR, 1);
        clickFolder(GENETICSFOLDER);
        clickFolder(PROJECT_NAME);
        PortalHelper portalHelper = new PortalHelper(this);
        portalHelper.addWebPart("EHR Datasets");

        clickFolder(COMPLIANCE_AND_TRAINING_FOLDER);
        setModuleProperties(Arrays.asList(new ModulePropertyValue("EHR_ComplianceDB", "/" +  getComplianceAndTrainingPath(), "EmployeeContainer", "/" + getComplianceAndTrainingPath())));
        storeCageAndRoomData();
        storeBreedingData();
        storeConceptionData();
        createPDLLinkedSchema();
        storePDLData();
        createBillingLinkedSchema();
        storeBillingData();
        initGenetics();
    }

    @Override
    protected void deleteHardTableRecords() throws CommandException, IOException
    {
        Map<String,Object> rowMap = new HashMap<>();
        rowMap.put("room", ROOM_AB5001);
        deleteIfNeeded("ehr_lookups", "rooms", rowMap, "room");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AB5001 + "-4");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AB5001 + "-14");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_AC5003);
        deleteIfNeeded("ehr_lookups", "rooms", rowMap, "room");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AC5003 + "-89");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AC5003 + "-43");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_AD5003);
        deleteIfNeeded("ehr_lookups", "rooms", rowMap, "room");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AD5003 + "-22");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AD5003 + "-23");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_3168659);
        deleteIfNeeded("ehr_lookups", "rooms", rowMap, "room");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_3168659 + "-1");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_3168659 + "-2");
        deleteIfNeeded("ehr_lookups", "cage", rowMap, "location");

        rowMap = new HashMap<>();
        rowMap.put("protocol", PROTOCOL_ID_10_CHAR_1);
        deleteIfNeeded("cnprc_ehr", "protocol", rowMap, "protocol");

        rowMap = new HashMap<>();
        rowMap.put("protocol", PROTOCOL_ID_10_CHAR_2);
        deleteIfNeeded("cnprc_ehr", "protocol", rowMap, "protocol");

        rowMap = new HashMap<>();
        rowMap.put("project", PROJECT_CODE_5_CHAR_0);
        deleteIfNeeded("cnprc_ehr", "project", rowMap, "rowid");

        rowMap = new HashMap<>();
        rowMap.put("project", PROJECT_CODE_5_CHAR_1);
        deleteIfNeeded("cnprc_ehr", "project", rowMap, "rowid");

        rowMap = new HashMap<>();
        rowMap.put("project", PROJECT_CODE_5_CHAR_2);
        deleteIfNeeded("cnprc_ehr", "project", rowMap, "rowid");

        rowMap = new HashMap<>();
        rowMap.put("pp_pk", 1);
        deleteIfNeeded("cnprc_ehr", "project_protocol", rowMap, "pp_pk");

        rowMap = new HashMap<>();
        rowMap.put("pp_pk", 2);
        deleteIfNeeded("cnprc_ehr", "project_protocol", rowMap, "pp_pk");
    }

    @Override
    protected void populateHardTableRecords() throws Exception
    {
        log("Inserting initial records into EHR hard tables");

        //verify delete first
        deleteHardTableRecords();

        Connection cn = new Connection(WebTestHelper.getBaseURL(), PasswordUtil.getUsername(), PasswordUtil.getPassword());

        //first cnprc_ehr.protocol
        InsertRowsCommand insertCmd = new InsertRowsCommand("cnprc_ehr", "protocol");
        Map<String,Object> rowMap = new HashMap<>();
        rowMap.put("protocol", PROTOCOL_ID_10_CHAR_1);
        rowMap.put("piPersonId", INVES_ID_1);
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("protocol", PROTOCOL_ID_10_CHAR_2);
        rowMap.put("piPersonId", INVES_ID_2);
        insertCmd.addRow(rowMap);
        insertCmd.execute(cn, getContainerPath());

        //then cnprc_ehr.project
        insertCmd = new InsertRowsCommand("cnprc_ehr", "project");
        rowMap = new HashMap<>();
        rowMap.put("projectCode", PROJECT_CODE_5_CHAR_0);
        rowMap.put("pi_name", PROJECT_INVESTIGATOR_NAME_2);
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("projectCode", PROJECT_CODE_5_CHAR_1);
        rowMap.put("pi_name", PROJECT_INVESTIGATOR_NAME_1);
        rowMap.put("unitCode", UNIT_CODE);
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("projectCode", PROJECT_CODE_5_CHAR_2);
        rowMap.put("pi_name", PROJECT_INVESTIGATOR_NAME_2);
        insertCmd.addRow(rowMap);
        insertCmd.execute(cn, getContainerPath());

        // cnprc_ehr.project_protocol
        insertCmd = new InsertRowsCommand("cnprc_ehr", "project_protocol");
        rowMap = new HashMap<>();
        rowMap.put("pp_pk", 1);
        rowMap.put("protocol_number", PROTOCOL_ID_10_CHAR_1);
        rowMap.put("projectCode", PROJECT_CODE_5_CHAR_0);
        rowMap.put("pp_assignment_date",  "2007-09-20");
        rowMap.put("pp_release_date", "2016-12-12");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("pp_pk", 2);
        rowMap.put("protocol_number", PROTOCOL_ID_10_CHAR_2);
        rowMap.put("projectCode", PROJECT_CODE_5_CHAR_1);
        rowMap.put("pp_assignment_date",  "2007-12-12");
        rowMap.put("pp_release_date", "2016-12-12");
        insertCmd.addRow(rowMap);
        insertCmd.execute(cn, getContainerPath());

        // cnprc_ehr.center_unit
        insertCmd = new InsertRowsCommand("cnprc_ehr", "center_unit");
        rowMap = new HashMap<>();
        rowMap.put("center_unit_code", UNIT_CODE);
        insertCmd.addRow(rowMap);
        insertCmd.execute(cn, getContainerPath());

        //then ehr_lookups.rooms
        insertCmd = new InsertRowsCommand("ehr_lookups", "rooms");
        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_AB5001);
        rowMap.put("housingType", 1);
        rowMap.put("housingCondition", 1);
        rowMap.put("area", "B");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_AC5003);
        rowMap.put("housingType", 1);
        rowMap.put("housingCondition", 1);
        rowMap.put("area", "A");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_AD5003);
        rowMap.put("housingType", 1);
        rowMap.put("housingCondition", 1);
        rowMap.put("area", "A");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("room", ROOM_3168659);
        rowMap.put("housingType", 1);
        rowMap.put("housingCondition", 1);
        rowMap.put("area", "A");
        insertCmd.addRow(rowMap);
        insertCmd.execute(cn, getContainerPath());

        //then ehr_lookups.cage
        insertCmd = new InsertRowsCommand("ehr_lookups", "cage");
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AB5001 + "-4");
        rowMap.put("room", ROOM_AB5001);
        rowMap.put("cage", "4");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AB5001 + "-14");
        rowMap.put("room", ROOM_AB5001);
        rowMap.put("cage", "14");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AC5003 + "-89");
        rowMap.put("room", ROOM_AC5003);
        rowMap.put("cage", "89");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AC5003 + "-43");
        rowMap.put("room", ROOM_AC5003);
        rowMap.put("cage", "43");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AD5003 + "-22");
        rowMap.put("room", ROOM_AD5003);
        rowMap.put("cage", "22");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_AD5003 + "-23");
        rowMap.put("room", ROOM_AD5003);
        rowMap.put("cage", "23");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_3168659 + "-1");
        rowMap.put("room", ROOM_3168659);
        rowMap.put("cage", "1");
        insertCmd.addRow(rowMap);
        rowMap = new HashMap<>();
        rowMap.put("location", ROOM_3168659 + "-2");
        rowMap.put("room", ROOM_3168659);
        rowMap.put("cage", "2");
        insertCmd.addRow(rowMap);
        insertCmd.execute(cn, getContainerPath());
    }

    protected void initGenetics() throws Exception
    {
        beginAt(WebTestHelper.buildURL("ehr", getProjectName(), "doGeneticCalculations"));
        clickButton("OK");
        waitForPipelineJobsToComplete(++_pipelineJobCount, "EHR Kinship Calculation", false, 10 * 60000);
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
    }

    @Override
    protected String getModuleDirectory()
    {
        return "cnprc_ehr";
    }

    @Override
    public BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("ehr", "cnprc_ehr", "cnprc_genetics");
    }

    @Nullable
    @Override
    protected String getProjectName()
    {
        return PROJECT_NAME;
    }

    @Override
    public String getFolderName() { return FOLDER_NAME; }

    @Override
    public String getContainerPath()
    {
        return PROJECT_NAME;
    }

    public String getGeneticsPath() { return PROJECT_NAME + "/" + COREFACILITIES + "/" + GENETICSFOLDER; }

    public String getComplianceAndTrainingPath() { return PROJECT_NAME + "/" + COREFACILITIES + "/" + COMPLIANCE_AND_TRAINING_FOLDER; }

    @Override
    protected void createProjectAndFolders(String type)
    {
        _containerHelper.createProject(getProjectName(), type);
        _containerHelper.createSubfolder(getProjectName(), getProjectName(), COREFACILITIES, "Collaboration", null);
        _containerHelper.createSubfolder(getProjectName(), COREFACILITIES, GENETICSFOLDER, "Laboratory Folder", new String[]{"SequenceAnalysis", "CNPRC_Genetics"});
        _containerHelper.createSubfolder(getProjectName(), COREFACILITIES, PDLFOLDER, "Collaboration", new String[]{"CNPRC_PDL"});
        _containerHelper.createSubfolder(getProjectName(), COREFACILITIES, BILLINGFOLDER, "Custom", new String[]{"CNPRC_Billing"});
        _containerHelper.createSubfolder(getProjectName(), COREFACILITIES, COMPLIANCE_AND_TRAINING_FOLDER, "Compliance and Training", new String[]{"CNPRC_ComplianceAndTraining"});
        clickFolder(getProjectName());
    }

    @Test
    public void testGenetics(){
        goToProjectHome();
        clickFolder(GENETICSFOLDER);
        waitAndClickAndWait(LabModuleHelper.getNavPanelItem(GENETICS_PANEL_LABEL, "Browse All"));
        DataRegionTable results = new DataRegionTable("Data", getDriver());
        final List<String> rowData = results.getRowDataAsText(results.getRowIndex("1"), "Subject", "Sex", "Sire", "Dam", "Lab Case", "Date Tested", "Notes");
        assertEquals("Bad genetics data",
                Arrays.asList("TEST1099252", "F", "TEST6390238", "TEST2312318", "PDA0123", "2003-02-14 00:00", "TEST1099252 qualifies as an offspring of TEST2312318 and TEST6390238."),
                rowData);
        results.assertPaginationText(1,100,222);
    }

    @Override
    protected void importStudy()
    {
        File path = new File(TestFileUtils.getLabKeyRoot(), getModulePath() + "/resources/referenceStudy");
        setPipelineRoot(path.getPath());

        beginAt(WebTestHelper.getBaseURL() + "/pipeline-status/" + getContainerPath() + "/begin.view");
        clickButton("Process and Import Data", defaultWaitForPage);

        _fileBrowserHelper.expandFileBrowserRootNode();
        _fileBrowserHelper.checkFileBrowserFileCheckbox("study.xml");

        if (isTextPresent("Reload Study"))
            _fileBrowserHelper.selectImportDataAction("Reload Study");
        else
            _fileBrowserHelper.selectImportDataAction("Import Study");

        //TODO: Later we may want to validate the queries?!
        Locator cb = Locator.checkboxByName("validateQueries");
        waitForElement(cb);
        uncheckCheckbox(cb);

        clickButton("Start Import"); // Validate queries page
        waitForPipelineJobsToComplete(++_pipelineJobCount, "Study import", false, MAX_WAIT_SECONDS * 2500);
    }

    @Override
    protected void populateInitialData()
    {
        beginAt(WebTestHelper.getBaseURL() + "/" + getModuleDirectory() + "/" + getContainerPath() + "/populateData.view");

        repopulate("Lookup Sets");
        repopulate("All");
        repopulate("SNOMED Codes");
    }

    @Test
    public void testCnprcFrontPageView()
    {
        BodyWebPart frontPage = new BodyWebPart(getDriver(), "Electronic Health Record");
        WebElement browseData = Locator.tagWithText("a", "Browse Data").findElement(frontPage);
        WebElement enterData = Locator.tagWithText("a", "Enter Data").findElement(frontPage);
        WebElement colonyOverview = Locator.tagWithText("a", "Colony Overview").findElement(frontPage);

        ControllerActionId actionId = new ControllerActionId(browseData.getAttribute("href"));
        assertEquals("Wrong controller-action for 'Browse Data", new ControllerActionId("ehr", "animalHistory"), actionId);

        actionId = new ControllerActionId(enterData.getAttribute("href"));
        assertEquals("Wrong controller-action for 'Enter Data", new ControllerActionId("ehr", "enterData"), actionId);

        actionId = new ControllerActionId(colonyOverview.getAttribute("href"));
        assertEquals("Wrong controller-action for 'Colony Overview", new ControllerActionId("ehr", "colonyOverview"), actionId);
    }

    @Test
    public void testCnprcCaseManagement() throws IOException, CommandException
    {
        log("Inserting the record with todays date");
        InsertRowsCommand insertCmd = new InsertRowsCommand("study", "morningHealthObs");
        ZonedDateTime now = ZonedDateTime.now();
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        Map<String,Object> rowMapMH = new HashMap<>();
        rowMapMH.put("Id","TEST3");
        rowMapMH.put("fileNum","1000001");
        rowMapMH.put("sequence","15");
        rowMapMH.put("recordType","D");
        rowMapMH.put("recordStatus","P");
        rowMapMH.put("obsCode1","POORAPP");
        rowMapMH.put("obsCode2","DEHYDRT");
        rowMapMH.put("remark","MORNING HEALTH REPORT-Updated");
        rowMapMH.put("date", dateTimeFormatter.format(now));
        insertCmd.addRow(rowMapMH);
        insertCmd.execute(createDefaultConnection(false), getContainerPath());

        EnterDataPage enterData = EnterDataPage.beginAt(this,getProjectName());

        log("Checking records for all cases");
        HashSet<String> expectedAllCases = new HashSet<>(Arrays.asList("D","H","L","MH","O","P"));
        enterData.waitAndClickAndWait(Locator.linkWithText("All Cases"));
        DataRegionTable allCasesTable = new DataRegionTable("query",getDriver());
        Set<String> ac = new HashSet<>(allCasesTable.getColumnDataAsText("AdmitType"));
        assertEquals("Missing admit type in list of all cases",expectedAllCases,ac);
        assertEquals("Wrong number of rows found in all cases",6,ac.size());

        log("Checking records morning health");
        enterData = EnterDataPage.beginAt(this,getProjectName());
        enterData.waitAndClickAndWait(Locator.linkWithText("Morning Health"));
        HashSet<String> expectedMorningHealth = new HashSet<>(Arrays.asList("MH"));
        DataRegionTable morningHealthTable = new DataRegionTable("query",getDriver());
        Set<String> mh = new HashSet<>(morningHealthTable.getColumnDataAsText("AdmitType"));
        assertEquals("Wrong Admit Type for Morning Health",expectedMorningHealth,mh);

        log("Checking records for hospital");
        enterData = EnterDataPage.beginAt(this,getProjectName());
        enterData.waitAndClickAndWait(Locator.linkWithText("Hospital"));
        DataRegionTable hospitalTable = new DataRegionTable("query",getDriver());
        Set<String> h = new HashSet<>(hospitalTable.getColumnDataAsText("AdmitType"));
        HashSet<String> expectedHospital = new HashSet<>(Arrays.asList("H"));
        assertEquals("Wrong Admit Type for Hospital",expectedHospital,h);

        log("Checking records for outpatient");
        enterData = EnterDataPage.beginAt(this,getProjectName());
        enterData.waitAndClickAndWait(Locator.linkWithText("Outpatient"));
        DataRegionTable outPatientTable = new DataRegionTable("query",getDriver());
        Set<String> op = new HashSet<>(outPatientTable.getColumnDataAsText("AdmitType"));
        HashSet<String> expectedOutpatient = new HashSet<>(Arrays.asList("O"));
        assertEquals("Wrong Admit Type for Outpatient",expectedOutpatient,op);

        log("Checking records for LTOP");
        enterData = EnterDataPage.beginAt(this,getProjectName());
        enterData.waitAndClickAndWait(Locator.linkWithText("LTOP"));
        DataRegionTable ltopTable = new DataRegionTable("query",getDriver());
        Set<String> ltop = new HashSet<>(ltopTable.getColumnDataAsText("AdmitType"));
        HashSet<String> expectedLTOP = new HashSet<>(Arrays.asList("L"));
        assertEquals("Wrong Admit Type for Long Term Outpatient",expectedLTOP,ltop);

        log("Checking records for post operation");
        enterData = EnterDataPage.beginAt(this,getProjectName());
        enterData.waitAndClickAndWait(Locator.linkWithText("Post-Operation"));
        DataRegionTable ppTable = new DataRegionTable("query",getDriver());
        Set<String> pp = new HashSet<>(ppTable.getColumnDataAsText("AdmitType"));
        HashSet<String> expectedPostOperation = new HashSet<>(Arrays.asList("P"));
        assertEquals("Wrong Admit Type for post operation",expectedPostOperation,pp);

    }

    @Test
    public void testCnprcCaseMgmPP2Remarks()
    {
        EnterDataPage enterData = EnterDataPage.beginAt(this,getProjectName());
        log("Checking records for all cases");
        enterData.waitAndClickAndWait(Locator.linkWithText("All Cases"));
        DataRegionTable allCasesTable = new DataRegionTable("query",getDriver());
        allCasesTable.setFilter("Id","Equals","44444");
        allCasesTable.setFilter("AdmitType","Equals","P");
        assertTrue("Wrong value in plan",allCasesTable.getColumnDataAsText("p").contains("Value for p-1"));
        assertTrue("Wrong value in p2(last entered)",allCasesTable.getColumnDataAsText("p2").contains("Value for p2-1"));
        assertTrue("Wrong value in remarks",allCasesTable.getColumnDataAsText("remark").contains("Value for remarks-1"));
    }


    @Test
    public void testCnprcColonyOverview()
    {
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        overviewPage.clickPopulationCompositionTab();
        waitForText("Total");
        assertTextPresentInThisOrder("Infant","Juvenile", "Adult","Geriatric");
        assertTextPresentInThisOrder("Total","0 - 6 mos","6 mos - 3.5 yrs","3.5 - 15 yrs","15+ yrs");
        Locator.XPathLocator linkLocator = Locator.linkContainingText("22");
        assertElementPresent(linkLocator);
        clickAndWait(linkLocator);
        DataRegionTable results = new DataRegionTable("query", getDriver());
        assertEquals("Wrong row count",22,results.getDataRowCount());
        assertTextPresent( "species = CMO","calculated_status = Alive");
    }

    @Test
    public void testCnprcColonyOverview_SPF()
    {
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        overviewPage.clickSpfColonyTab();
        waitForText("Total");
        assertTextPresentInThisOrder("Infant","Juvenile", "Adult","Geriatric");
        assertTextPresentInThisOrder("Total","0 - 6 mos","6 mos - 3.5 yrs","3.5 - 15 yrs","15+ yrs");
        Locator.XPathLocator linkLocator = Locator.linkWithText("8");
        clickAndWait(linkLocator);
        DataRegionTable results = new DataRegionTable("query", getDriver());
        assertEquals("Wrong row count",8,results.getDataRowCount());
        assertTextPresent( "spf = 0","species = CMO","calculated_status = Alive");
        assertTextPresent("TEST2008446","TEST3804589","TEST3997535","TEST1",
                "TEST4710248","TEST2","TEST7151371","TEST7407382");
    }

    @Test
    public void testCnprcColonyOverview_HousingSummary()
    {
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        overviewPage.clickHousingSummaryTab();
        waitForText("Area Usage:");
        assertTextPresentInThisOrder(
                "Area Usage:",
                "Area","Total Cages","Empty Cages","MMU Count","CMO Count","MCY Count","Unknown","% Used",
                "Housing Type Summary:",
                "Pairing Summary:");
        Locator.XPathLocator linkLocator = Locator.linkWithText("A:");
        click(linkLocator);
        switchToWindow(1);
        waitForText("Room Utilization:");
        DataRegionTable results = new DataRegionTable("query", getDriver());
        assertEquals("Wrong row count",3,results.getDataRowCount());
        List<String> expected = Arrays.asList("3168659","2","2","2","0","100.0","2","0","2","0","0");
        assertEquals("Wrong row text.", expected,results.getRowDataAsText(0));
    }

    @Test
    public void testCnprcColonyOverview_CCS()
    {
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        WebElement ccsColonyTab = overviewPage.clickCcsColonyTab();
        waitForText("Category");
        assertEquals("Wrong column headers", Arrays.asList("Category", "Total", "%")
                , getTexts(Locator.css("tr:nth-of-type(1)> td").findElements(ccsColonyTab)));
        Locator.XPathLocator linkLocator = Locator.linkWithText("1");
        clickAndWait(linkLocator);
        DataRegionTable results = new DataRegionTable("query", getDriver());
        assertEquals("Wrong row count",1,results.getDataRowCount());
        assertTextPresent( "admitType.description = Diabetic", "TEST2008446");
    }

    @Test
    public void testCnprcColonyOverview_Utilization()
    {
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        WebElement utilizationColonyTab = overviewPage.clickUtilizationColonyTab();
        waitForText("Category");
        assertEquals("Wrong column headers", Arrays.asList("Category", "Total", "%")
                , getTexts(Locator.css("tr:nth-of-type(1)> td").findElements(utilizationColonyTab)));
        WebElement linkElement = Locator.tag("tr").withDescendant(Locator.tagWithText("div","Base Grant")).append(Locator.tagWithText("a","2")).findElement(utilizationColonyTab);

        clickAndWait(linkElement);
        DataRegionTable results = new DataRegionTable("query", getDriver());
        assertEquals("Wrong row count",2,results.getDataRowCount());
        assertTextPresent( "fundingCategory = 'Base Grant'", "TEST1684145", "TEST6390238");
    }

    @Test
    public void testTreatments()
    {
        click(Locator.linkWithText("Browse All Datasets"));
        waitForElement(Locator.linkContainingText("Browse All"));
        waitAndClickAndWait(LabModuleHelper.getNavPanelItem("Treatment Orders:", "Browse All"));
        waitForElement(Locator.linkContainingText(CNPRC_ANIMAL));
        pushLocation();
        clickAndWait(Locator.linkContainingText("TP"));
        popLocation();
        waitForElement(Locator.linkContainingText("TEST3804589"));
        assertTextPresent("PEANUTS");
    }

    private void storeConceptionData() throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        String folder = "/";
        insertTsvData(connection, "cnprc_ehr", "conceptions", CNPRC_EHR_CONCEPTIONS_TSV, folder);
    }

    @Test
    public void testAnimalHistoryReports() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);

        animalHistoryPage.searchSingleAnimal(CNPRC_ANIMAL);
        _helper.verifyReportTabs(animalHistoryPage, CNPRC_REPORTS);
    }

    @Test
    public void testPathologyAndSNOMEDImageLinks() throws Exception
    {
        storeImageData();

        //Necropsy
        click(Locator.linkWithText("Browse All Datasets"));
        waitForElement(Locator.linkContainingText("Browse All"));
        pushLocation();
        waitAndClickAndWait(LabModuleHelper.getNavPanelItem("Necropsies:", "Browse All"));
        waitForElement(Locator.linkContainingText("TEST2950014"));
        clickAndWait(Locator.linkContainingText("XY000001"));
        assertTextPresent("TEST2950014");
        popLocation();

        //SNOMED
        /*TODO: Per support ticket 31631. Removed image link from SNOMED but may add it back in Milestone 5 so just
            commenting this out for now.
         */
//        waitAndClickAndWait(LabModuleHelper.getNavPanelItem("SNOMED:", "Browse All"));
//        waitForElement(Locator.linkContainingText("TEST3804589"));
//        pushLocation();
//        clickAndWait(Locator.linkContainingText("XY000006"));
//        assertTextPresent("KIDNEY");
//        popLocation();
    }

    private void storeImageData() throws Exception
    {
        Connection connection = createDefaultConnection(true);

        InsertRowsCommand command = new InsertRowsCommand("cnprc_ehr", "image");
        List<Map<String, Object>> imageTsv = loadTsv(IMAGE_TSV);
        command.setRows(imageTsv);
        command.execute(connection, getProjectName());

        command = new InsertRowsCommand("cnprc_ehr", "image_pathology");
        List<Map<String, Object>> imagePathologyTsv = loadTsv(IMAGE_PATHOLOGY_TSV);
        command.setRows(imagePathologyTsv);
        command.execute(connection, getProjectName());

        command = new InsertRowsCommand("cnprc_ehr", "image_snomed");
        List<Map<String, Object>> imageSnomedTsv = loadTsv(IMAGE_SNOMED_TSV);
        command.setRows(imageSnomedTsv);
        command.execute(connection, getProjectName());
    }

    @Test
    public void testPDLlookups() throws Exception
    {
        goToProjectHome();
        clickFolder(PDLFOLDER);
        _listHelper.importListArchive(LOOKUP_LIST_ARCHIVE);

        validateLookupFromList("Billing Contact", "Client 100", "Client full name 100");
        validateLookupFromList("Processing Item", "Sample type 300", "Sample type comment 300");
        validateLookupFromList("Processing Item", "Test type 600", "Test type comment 600");
        validateLookupFromList("Report Contact", "Client 101", "Client full name 101");
        validateLookupFromList("Sub Test Types", "Test type 600", "Panel test type 2");
        validateLookupFromList("Sub Test Types", "Test type 601", "Test type comment 601");


//TODO enable once PDL is signed off.  May require some adjustment to the Client lookup in orders.query.xml
//      validateLookupFromTable("orders", "Client 100", "Client full name 100");
//        validateLookupFromTable("orders", "Billing contact 100", "Billing contact 100 comment");
//        validateLookupFromTable("orders", "Report contact 100", "Report contact comment 0");

        validateLookupFromTable("samples", "100", "Order comment 1");
        validateLookupFromTable("samples", "TEST1020148", "Overview: TEST1020148");
//TODO enable once PDL is signed off.
//        validateLookupFromTable("samples", "Sample type 300", "Sample type comment 300");

        validateLookupFromTable("tests", "200", "Sample 200 comment");

        validateLookupFromTable("sub_tests", "400", "Test Comment 400");
    }

    @Test
    public void testClinicalHistoryPanelOptions()
    {
        beginAtAnimalHistoryTab();
        openClinicalHistoryForAnimal("TEST1020148");
        List<String> expectedLabels = new ArrayList<>(
                Arrays.asList(
                        "Labwork",
                        "Weights",
                        "Housing Transfers",
                        "Blood Draws",
                        "Clinical",
                        "Assignments",
                        "Births",
                        "Deaths",
                        "Arrival/Departure"
                ));
        checkClinicalHistoryType(expectedLabels);
    }

    @Test
    public void testInfantReport() throws Exception
    {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new Date());
        calendar.add(Calendar.DAY_OF_YEAR, -50);
        setParticipantDeathDate("TEST1441142", calendar.getTime());//Will not be included because not Alive
        calendar.add(Calendar.DAY_OF_YEAR, -50);
        setParticipantBirthDate("TEST2008446", calendar.getTime());
        setParticipantBirthDate("TEST1441142", calendar.getTime());//Will not be included because not Alive
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.findElement(Locator.tagWithAttributeContaining("input","value","Alive, at Center")).click();
        searchPanel.setView("Infant Report");
        DataRegionTable searchResults = searchPanel.submit();

        List<String> expectedColumns = Arrays.asList(
                "Id",
                "Id/curLocation/Location",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/DemographicsActiveAssignment/secondaryProjects",
                "gender/code",
                "Id/age/yearsAndMonths",
                "Id/MostRecentWeight/MostRecentWeight",
                "Id/activeFlagList/values",
                "dam",
                "dam/activeFlagList/values",
                "sire",
                "sire/activeFlagList/values"
        );
        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());

        assertElementPresent(Locator.linkWithText("TEST2008446"));
        assertEquals("Wrong number of rows: ", 1, searchResults.getDataRowCount());
    }

    @Test
    public void testCageViolationReport() throws Exception
    {
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.findElement(Locator.tagWithAttributeContaining("input","value","Alive, at Center")).click();
        searchPanel.setView("Cage Violation Report");
        DataRegionTable searchResults = searchPanel.submit();

        List<String> expectedColumns = Arrays.asList(
                "Id",
                "Id/curLocation/Location",
                "gender/code",
                "Id/MostRecentWeight/MostRecentWeight",
                "Id/cageViolation/cage_size",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/cageViolation/behavior_code",
                "Id/activeFlagList/values"
        );
        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());

        assertElementPresent(Locator.linkWithText("TEST4564246"));
        assertEquals("Wrong number of rows: ", 1, searchResults.getDataRowCount());
    }


    @Test
    public void testLTOPReport() throws IOException, CommandException
    {
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.findElement(Locator.tagWithAttributeContaining("input","value","Alive, at Center")).click();
        searchPanel.setView("LTOP Report");
        DataRegionTable searchResults = searchPanel.submit();

        List<String> expectedColumns = Arrays.asList(
                "Id",
                "Id/curLocation/location",
                "gender/code",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/age/yearsAndMonths",
                "Id/DemographicsActiveLongTermCases/date",
                "Id/DemographicsActiveLongTermCases/problems",
                "Id/DemographicsActiveLongTermCases/remarks");
        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());

        assertEquals("Wrong number of rows: ", 3, searchResults.getDataRowCount());
        assertElementPresent(Locator.linkWithText("TEST6390238"));
        assertEquals("Wrong value for Primary Project: ", "Pc5C1", searchResults.getDataAsText(2,3));
        assertEquals("Wrong value for Comment: ", "DERMATITIS AX &CHEST", searchResults.getDataAsText(2,6));
        assertEquals("Wrong value for History: ", "TEST HISTORY REMARK", searchResults.getDataAsText(2,7));
    }

    @Test
    public void testHybridReport() throws IOException, CommandException
    {
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.findElement(Locator.tagWithAttributeContaining("input","value","Alive, at Center")).click();
        searchPanel.setView("Hybrid Report");
        DataRegionTable searchResults = searchPanel.submit();
        List<String> expectedColumns = Arrays.asList(
                "Id",
                "gender/code",
                "Id/age/yearsAndMonths",
                "Id/curLocation/location",
                "Id/MostRecentWeight/MostRecentWeight",
                "Id/DemographicsActiveColony/colonyCode",
                "spf",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/DemographicsActivePayor/payor_ids",
                "Id/DemographicsActiveAssignment/secondaryProjects",
                "Id/flagList/values",
                "Id/Gestation/Gestation"
        );

        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());
        assertEquals("Wrong number of rows: ", 1, searchResults.getDataRowCount());
        assertElementPresent(Locator.linkWithText("TEST1112911"));
        assertEquals("Wrong value for Flags: ", "CH12, HGL2", searchResults.getDataAsText(0,10));
        assertEquals("Wrong value for Primary Project: ", PROJECT_CODE_5_CHAR_1, searchResults.getDataAsText(0,7));
    }

    @Test
    public void testNcRoundupReport() throws IOException, CommandException
    {
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.findElement(Locator.tagWithAttributeContaining("input","value","Alive, at Center")).click();
        searchPanel.setView("NC Roundup Report");
        DataRegionTable searchResults = searchPanel.submit();
        List<String> expectedColumns = Arrays.asList(
                "Id",
                "Id/HomeLocation/Room",
                "Id/NcRoundup/hoLocation",
                "Id/age/yearsAndMonths",
                "Id/MostRecentWeight/MostRecentWeight",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/DemographicsActiveAssignment/secondaryProjects",
                "Id/NcRoundup/VAS",
                "Id/DemographicsHolds/holdFlags",
                "Id/flagList/values",
                "Id/NcRoundup/Geriatric",
                "Id/NcRoundup/Tetanus",
                "Id/NcRoundup/Measles",
                "Id/NcRoundup/SerumBank",
                "Id/NcRoundup/VGL",
                "Id/NcRoundup/Dam"        );

        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());

        assertElementPresent(Locator.linkWithText("TEST1112911"));
        assertEquals("Wrong value for Primary Project: ", PROJECT_CODE_5_CHAR_1, searchResults.getDataAsText(3,5));
        assertEquals("Wrong value for HGL2 Flag: ", "HGL2", searchResults.getDataAsText(3,8));
        assertEquals("Wrong value for Flags: ", "CH12, HGL2", searchResults.getDataAsText(3,9));
        assertEquals("Wrong value for Measles: ", "X", searchResults.getDataAsText(3,13));
        assertEquals("Wrong value for Tetanus: ", "X", searchResults.getDataAsText(3,12));
        assertEquals("Wrong value for Serum Bank: ", "X", searchResults.getDataAsText(3,14));
    }

    @Test
    public void testCurrentPregnanciesReport() throws IOException, CommandException
    {
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.findElement(Locator.tagWithAttributeContaining("input","value","Alive, at Center")).click();
        searchPanel.setView("Current Pregnancies Report");
        DataRegionTable searchResults = searchPanel.submit();
        List<String> expectedColumns = Arrays.asList(
                "Id/DemographicsHolds/holdFlags",
                "Id/DemographicsActivePairingCode/observation",
                "Id/curLocation/Location",
                "Id/curLocation/cageSize",
                "Id/curLocation/rateClass",
                "Id",
                "species/code",
                "Id/age/yearsAndMonthsAndDays",
                "Id/MostRecentWeight/MostRecentWeight",
                "Id/curLocation/Date",
                "Id/DemographicsActivePayor/payor_ids",
                "Id/DemographicsActiveColony/colonyCode",
                "Id/DemographicsActiveBreedingGroup/groupCode",
                "Id/breedingRoster/book",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/DemographicsActiveAssignment/secondaryProjects",
                "Id/flagList/values",
                "Id/DemographicsActivePregnancy/conNum",
                "Id/DemographicsActivePregnancy/termComment",
                "Id/DemographicsActivePregnancy/PGComment",
                "Id/DemographicsActivePregnancy/daysPregnant",
                "Id/DemographicsActivePregnancy/conceptionDateStatus",
                "Id/curLocation/supervisor"
        );

        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());
        assertEquals("Wrong row count",2,searchResults.getDataRowCount());

        assertElementPresent(Locator.linkWithText("TSTCP"));
        int startColumnIndex = 2;
        int rowIndex = searchResults.getRowIndex("Id", "TSTCP");
        assertEquals("Wrong value for Location: ","AC500389" , searchResults.getDataAsText(rowIndex, startColumnIndex));
        assertEquals("Wrong value for Cage Size: ","4" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Rate Class: ","N" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Id: ","TSTCP" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Species: ","MMU" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        ++startColumnIndex;
        assertEquals("Wrong value for Weight: ","7.5" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Location Date: ","2013-02-19" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        ++startColumnIndex;
        assertEquals("Wrong value for Colony Code: ","L" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Breeding Code: ","M" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Breeding Book: ","BP" , searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Primary Project: ", PROJECT_CODE_5_CHAR_1, searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Secondary Projects: ", "Pc5C2, 1101324", searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Census Flag List: ", "CHU", searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Pregnancy: ", "PRG-1111", searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Term Comment: ", "TRM CMMNT", searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for PG Comment: ", "Not Completed", searchResults.getDataAsText(rowIndex,++startColumnIndex));
        ++startColumnIndex;
        assertEquals("Wrong value for Enst: ", " ", searchResults.getDataAsText(rowIndex,++startColumnIndex));
        assertEquals("Wrong value for Encl Supervisor: ", "Jane Jones", searchResults.getDataAsText(rowIndex,++startColumnIndex));
    }

    @Test
    public void testTbOverdueReport() throws IOException, CommandException
    {
        SearchPanel searchPanel = getSearchPanel();

        searchPanel.setView("TB Overdue Report");
        DataRegionTable searchResults = searchPanel.submit();
        List<String> expectedColumns = Arrays.asList(
                "Id",
                "Id/curLocation/Location",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/DemographicsActivePregnancy/conNum",
                "Id/DemographicsActivePregnancy/daysPregnant",
                "Id/TB Report/daysWeightOverdue",
                "Id/TB Report/daysTBOverdue",
                "Id/MostRecentWeight/MostRecentWeightDate",
                "Id/DemographicsMostRecentTB/MostRecentTBDate"
        );

        assertEquals("Wrong columns", expectedColumns, searchResults.getColumnNames());

        Calendar calendar = Calendar.getInstance();
        calendar.set(2015,Calendar.APRIL,21);
        Date lastTB = calendar.getTime();
        String daysOverdue = String.valueOf((int) ((new Date().getTime() - lastTB.getTime())/(1000 *60*60*24)-180));


        assertElementPresent(Locator.linkWithText("TEST1684145"));

        assertElementPresent(Locator.linkWithText("TEST1112911"));
        assertElementPresent(Locator.linkWithText("2011-09-09 09:00"));
        assertElementPresent(Locator.linkWithText("2015-04-21"));
        assertEquals("Wrong value for Primary Project: ", PROJECT_CODE_5_CHAR_1, searchResults.getDataAsText(3,2));
        assertEquals("Wrong value for Days TB Overdue: ", daysOverdue, searchResults.getDataAsText(3,6));

        insertWeightAndTBfor("TEST1684145");
        searchPanel = getSearchPanel();

        searchPanel.setView("TB Overdue Report");
        searchPanel.submit();
        assertElementNotPresent(Locator.linkWithText("TEST1684145"));
    }

    private void insertWeightAndTBfor(String id) throws IOException, CommandException
    {
        InsertRowsCommand insertCmdTB1 = new InsertRowsCommand("study", "tb");
        Map<String,Object> rowMapTB_1 = new HashMap<>();
        rowMapTB_1.put("id", id);
        rowMapTB_1.put("date", new Date());
        rowMapTB_1.put("test"               ,"Test1");
        rowMapTB_1.put("testType"           ,"type");
        rowMapTB_1.put("site"               ,"site");
        rowMapTB_1.put("twentyFourHrsResult","24");
        rowMapTB_1.put("fortyEightHrsResult","48");
        rowMapTB_1.put("seventyTwoHrsResult","72");
        rowMapTB_1.put("QCStateLabel","In Progress");

        insertCmdTB1.addRow(rowMapTB_1);
        SaveRowsResponse respTB =  insertCmdTB1.execute(createDefaultConnection(true), getProjectName());

        InsertRowsCommand insertCmdTB2 = new InsertRowsCommand("study", "tb");
        Map<String,Object> rowMapTB_2 = new HashMap<>();
        rowMapTB_2.put("id"                 , id        );
        rowMapTB_2.put("date"               , new Date());
        rowMapTB_2.put("test"               ,"Test2"    );
        rowMapTB_2.put("testType"           ,"type2"    );
        rowMapTB_2.put("site"               ,"site2"    );
        rowMapTB_2.put("twentyFourHrsResult","24"       );
        rowMapTB_2.put("fortyEightHrsResult","48"       );
        rowMapTB_2.put("seventyTwoHrsResult","72"       );
        rowMapTB_2.put("QCStateLabel","In Progress");
        insertCmdTB2.addRow(rowMapTB_2);

        SaveRowsResponse respTB2 =  insertCmdTB2.execute(createDefaultConnection(true), getProjectName());

        InsertRowsCommand insertCmdWeight = new InsertRowsCommand("study", "weight");
        Map<String,Object> rowMapWeight = new HashMap<>();
        rowMapWeight.put("id", id);
        rowMapWeight.put("date", new Date());
        rowMapWeight.put("weight", "2.9");
        rowMapWeight.put("weightTattooFlag", "X");
        rowMapWeight.put("bodyConditionScore", "3");
        insertCmdWeight.addRow(rowMapWeight);
        SaveRowsResponse respWeight =  insertCmdWeight.execute(createDefaultConnection(false), getContainerPath());
    }

    @Test
    public void testSerumBankReport() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Repository");
        animalHistoryPage.clickReportTab("Serum Bank");

        DataRegionTable historyTable = animalHistoryPage.getActiveReportDataRegion();

        List<String> expectedColumns = Arrays.asList(
                "Id",
                "date",
                "locationBox",
                "locationSlot",
                "viralPrecautionFlag"
        );
        assertEquals("Wrong columns", expectedColumns, historyTable.getColumnNames());

        assertElementPresent(Locator.linkWithText("TEST9118022"));
        assertElementPresent(Locator.tagContainingText("nobr", "2015-09-30 00:00"));
    }

    @Test
    public void testHousingHistoryReport() throws IOException, CommandException
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Colony Management");
        animalHistoryPage.clickReportTab("Housing History");

        DataRegionTable historyTable = animalHistoryPage.getActiveReportDataRegion();

        List<String> expectedColumns = Arrays.asList(
                "Id/Demographics/species",
                "Id",
                "room",
                "cage",
                "date",
                "enddate",
                "reason",
                "reloc_seq"
                );
        assertEquals("Wrong columns", expectedColumns, historyTable.getColumnNames());

        assertEquals("Wrong Housing History results,",
                Arrays.asList("TEST4564246", "2005-01-11 14:00", " ", "<6824778>", "4953547"),
                historyTable.getRowDataAsText(7, "Id", "date", "enddate", "room", "cage"));
    }

    @Test
    public void testVacantCageReport() throws IOException, CommandException
    {
        log("Quick Search - Advanced Housing Search - Vacant Cages Report");
        openMenu("Quick Search");
        waitForElement(Locator.linkWithText("Advanced Housing Search"), WAIT_FOR_JAVASCRIPT);
        clickAndWait(Locator.linkWithText("Advanced Housing Search"));
        waitAndClickAndWait(Locator.linkWithText("Vacant Cage Summary"));

        DataRegionTable results = new DataRegionTable("query", getDriver());


        List<String> expectedColumns = Arrays.asList(
                "enclosure",
                "cage_size",
                "Animals",
                "cageOccupancy",
                "cages",
                "emptyCages"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        String[] expected = {
                ROOM_AB5001
                , "4"
                , "1"
                , "1"
                , "2"
                , "4"
        };
        List<String> resultsRowDataAsText = results.getRowDataAsText(0);
        String[] rowDataAsText = resultsRowDataAsText.toArray(new String[resultsRowDataAsText.size()]);
        for (int i = 0; i < expected.length; i++)
        {
            assertEquals("Wrong value: ", expected[i], rowDataAsText[i]);
        }

        assertEquals("Wrong row count: ", 1, results.getDataRowCount());

    }

    @Test
    public void testTenPercentWeightDropReport() throws IOException, CommandException
    {
        insertWeights();

        SearchPanel searchPanel = getSearchPanel();  // just using this to go to the search panel
        clickAndWait(Locator.linkWithText("10%/20% Weight Drop"));

        DataRegionTable results = new DataRegionTable("query", getDriver());

        List<String> expectedColumns = Stream.of("Id",
                "LatestWeightDate",
                "LatestWeight",
                "IntervalInDays",
                "IntervalInMonths",
                "OldWeight",
                "PctChange").collect(Collectors.toList());

        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        List<String> expected = Arrays.asList(
                "TEST3771679"
                , "9.1"
                , "75"
                , "2"
                , "13.0"
                , "-30.0"
        );
        expectedColumns.remove("LatestWeightDate"); // always changes each time test is run, don't look in data for this
        List<String> resultsRowDataAsText = results.getRowDataAsText(0, expectedColumns.toArray(new String[expectedColumns.size()]));
        assertEquals("Wrong data for first weight drop with these columns: " + expectedColumns.toString(), resultsRowDataAsText, expected);

        expected = Arrays.asList(
                "TEST4037096"
                , "9.89"
                , "50"
                , "1"
                , "11.0"
                , "-10.1"
        );

        resultsRowDataAsText = results.getRowDataAsText(1, expectedColumns.toArray(new String[expectedColumns.size()]));
        assertEquals("Wrong data for second weight drop with these columns: " + expectedColumns.toString(), resultsRowDataAsText, expected);

        assertEquals("Wrong row count: ", 2, results.getDataRowCount());

    }

    private void insertWeights() throws IOException, CommandException
    {
        InsertRowsCommand insertCmd = new InsertRowsCommand("study", "weight");

        ZonedDateTime now = ZonedDateTime.now();
        ZonedDateTime fiftyDaysAgo = now.minusDays(50);
        ZonedDateTime seventyFiveDaysAgo = now.minusDays(75);
        ZonedDateTime oneHundredSeventyDaysAgo = now.minusDays(170);
        ZonedDateTime twoHundredDaysAgo = now.minusDays(200);
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        Map<String,Object> rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "9.1");
        rowMapWeights.put("date", dateTimeFormatter.format(now));
        rowMapWeights.put("Id", "TEST3771679");
        rowMapWeights.put("Description", "TEST3771679-1");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "12.0");
        rowMapWeights.put("date", dateTimeFormatter.format(fiftyDaysAgo));
        rowMapWeights.put("Id", "TEST3771679");
        rowMapWeights.put("Description", "TEST3771679-2");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "13.0");
        rowMapWeights.put("date", dateTimeFormatter.format(seventyFiveDaysAgo));
        rowMapWeights.put("Id", "TEST3771679");
        rowMapWeights.put("Description", "TEST3771679-3");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "9.89");
        rowMapWeights.put("date", dateTimeFormatter.format(now));
        rowMapWeights.put("Id", "TEST4037096");
        rowMapWeights.put("Description", "TEST4037096-1");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "11.0");
        rowMapWeights.put("date", dateTimeFormatter.format(fiftyDaysAgo));
        rowMapWeights.put("Id", "TEST4037096");
        rowMapWeights.put("Description", "TEST4037096-2");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "10.5");
        rowMapWeights.put("date", dateTimeFormatter.format(seventyFiveDaysAgo));
        rowMapWeights.put("Id", "TEST4037096");
        rowMapWeights.put("Description", "TEST4037096-3");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "10.0");
        rowMapWeights.put("date", dateTimeFormatter.format(now));
        rowMapWeights.put("Id", "TEST7407382");
        rowMapWeights.put("Description", "TEST7407382-1");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "15.0");
        rowMapWeights.put("date", dateTimeFormatter.format(twoHundredDaysAgo));
        rowMapWeights.put("Id", "TEST7407382");
        rowMapWeights.put("Description", "TEST7407382-2");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "10.0");
        rowMapWeights.put("date", dateTimeFormatter.format(now));
        rowMapWeights.put("Id", "44445");
        rowMapWeights.put("Description", "44445-1");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "12.0");
        rowMapWeights.put("date", dateTimeFormatter.format(fiftyDaysAgo));
        rowMapWeights.put("Id", "44445");
        rowMapWeights.put("Description", "44445-2");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "13.0");
        rowMapWeights.put("date", dateTimeFormatter.format(seventyFiveDaysAgo));
        rowMapWeights.put("Id", "44445");
        rowMapWeights.put("Description", "44445-3");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "10.0");
        rowMapWeights.put("date", dateTimeFormatter.format(oneHundredSeventyDaysAgo));
        rowMapWeights.put("Id", "44446");
        rowMapWeights.put("Description", "44446-1");
        insertCmd.addRow(rowMapWeights);
        rowMapWeights = new HashMap<>();
        rowMapWeights.put("weight", "14.0");
        rowMapWeights.put("date", dateTimeFormatter.format(twoHundredDaysAgo));
        rowMapWeights.put("Id", "44446");
        rowMapWeights.put("Description", "44446-2");
        insertCmd.addRow(rowMapWeights);
        insertCmd.execute(createDefaultConnection(false), getContainerPath());
    }

    @Test
    public void testLocationReport() throws IOException, CommandException
    {
        click(Locator.linkWithText("Housing Queries"));
        waitForElement(Locator.tagContainingText("div", "On Date"));
        // Enclosure Search is backed by LocationReport query
        SearchPanel searchPanel = new SearchPanel("Enclosure Search", getDriver());
        searchPanel.submit();
        DataRegionTable results = new DataRegionTable("query", getDriver());
        // Pick a row with a good pairing indicator
        int rowIndex = results.getRowIndex("Id", "TEST1112911");
        List<String> expectedColumns = Arrays.asList(
                "Id",
                "pairingIndicator",
                "location",
                "room",
                "cage",
                "cage_size",
                "rate_class",
                "species",
                "gender",
                "age",
                "MostRecentWeight",
                "date",
                "payor_ids",
                "colonyCode",
                "groupCode",
                "book",
                "primaryProject",
                "secondaryProjects",
                "values",
                "conNum",
                "pgComment",
                "daysPregnant",
                "conceptionDateStatus",
                "supervisor"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        assertEquals("Wrong Housing History link,",
                Arrays.asList("TEST1112911", "2005-02-19 14:00", "3168659", "1"),
                results.getRowDataAsText(rowIndex, "Id", "date", "room", "cage"));
    }

    @Test
    public void testEnclosureSearch() throws IOException, CommandException, URISyntaxException
    {
        click(Locator.linkWithText("Housing Queries"));
        waitForElement(Locator.tagContainingText("div", "On Date"));
        SearchPanel searchPanel = new SearchPanel("Enclosure Search", getDriver());
        searchPanel.submit();
        DataRegionTable results = new DataRegionTable("query", getDriver());
        int rowIndex = results.getRowIndex("Id", "44444");

        // Test from housing data
        // Choosing this row (and these columns) because there are data from all tables populated
        // Note that current date data is, by design, sometimes blank for these fields though

        assertEquals("Wrong Enclosure Search results from housing table using current date,",
                Arrays.asList("44444", "AC5003", "89", "4", "MMU", "5.5", " ", "L", " ", "BO", " ", " ", " ", "Not Completed", "Jane Jones"),
                results.getRowDataAsText(rowIndex, "Id", "room", "cage", "cage_size", "species", "MostRecentWeight", "payor_ids", "colonyCode",
                        "groupCode", "book", "primaryProject", "secondaryProjects", "values", "pgComment", "supervisor"));

        // Now test that historical data changes on same info
        goBack();
        waitForElement(Locator.tagContainingText("div", "On Date"));
        searchPanel = new SearchPanel("Enclosure Search", getDriver());
        searchPanel.setInput("On Date", "2015-04-04 00:00:00");
        searchPanel.submit();
        results = new DataRegionTable("query", getDriver());
        rowIndex = results.getRowIndex("Id", "44444");

        assertEquals("Wrong Enclosure Search results from housing table using historical date,",
                Arrays.asList("44444", "AC5003", "89", "6", "MMU", "4.4", "AB125/YZ17", "O", "M", "BO", "Pc5C0", "Pc5C1, Pc5C2", "CHA, CHU", "Completed", "Jane Jones"),
                results.getRowDataAsText(rowIndex, "Id", "room", "cage", "cage_size", "species", "MostRecentWeight", "payor_ids", "colonyCode",
                        "groupCode", "book", "primaryProject", "secondaryProjects", "values", "pgComment", "supervisor"));

        // Test from departure data too
        // Choosing this row because it has most entries populated
        // NOTE: commented out in test because Enclosure Search no longer returns departure records

        /*assertEquals("Wrong Enclosure Search results from departure table using historical date,",
                Arrays.asList("44446", "3105069X4", " ", "MMU", "6.6", "AB126/YZ18", " ", "T", "C2", "Pc5C2", " ", "CHU", "Completed", " "),
                results.getRowDataAsText(1, "Id", "location", "cage_size", "species", "MostRecentWeight", "payor_ids", "colonyCode",
                        "groupCode", "book", "primaryProject", "secondaryProjects", "values", "pgComment", "supervisor"));*/
    }

    private void storeCageAndRoomData() throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        String folder = "/";
        insertTsvData(connection, "cnprc_ehr", "cage_location_history", CNPRC_EHR_CAGE_LOCATION_HISTORY, folder);
        insertTsvData(connection, "cnprc_ehr", "room_enclosure", CNPRC_EHR_ROOM_ENCLOSURE, folder);
    }

    private void storeTestTypeMappingData() throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        String folder = "/";
        insertTsvData(connection, "ehr_lookups", "virology_sample_type", EHR_LOOKUP_VIROLOGY_SAMPLE_TYPE, folder);
        insertTsvData(connection, "ehr_lookups", "test_type_virus_mapping", EHR_LOOKUP_TEST_VIRUS_MAPPING, folder);
        insertTsvData(connection, "ehr_lookups", "test_type_target_mapping", EHR_LOOKUP_TEST_TARGET_MAPPING, folder);
        insertTsvData(connection, "ehr_lookups", "test_type_method_mapping", EHR_LOOKUP_TEST_METHOD_MAPPING, folder);
    }

    private void storeBreedingData() throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        String folder = "/";
        insertTsvData(connection, "cnprc_ehr", "breedingRoster", CNPRC_EHR_BREEDING_ROSTER, folder);
    }

    private void setParticipantBirthDate(String id, Date birthdate) throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        List<Map<String, Object>> demoRows = Arrays.asList(
                Maps.of("id", id,
                        "birth", DATE_FORMAT.format(birthdate)
                )
        );

        UpdateRowsCommand command = new UpdateRowsCommand("study", "demographics");
        command.setRows(demoRows);
        command.execute(connection, getProjectName());
    }

    private void setParticipantDeathDate(String id, Date deathdate) throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        List<Map<String, Object>> deathsRows = Arrays.asList(
                Maps.of("id", id,
                        "date", DATE_FORMAT.format(deathdate)
                )
        );

        UpdateRowsCommand command = new UpdateRowsCommand("study", "deaths");
        command.setRows(deathsRows);
        command.execute(connection, getProjectName());
    }

    @Test
    public void testAnimalHistoryProjectView() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Assignments and Groups");
        animalHistoryPage.clickReportTab("Project Assignment History");
        animalHistoryPage.searchSingleAnimal("TEST1112911");
        click(Locator.linkContainingText(PROJECT_CODE_5_CHAR_1));

        switchToWindow(1);

        DataRegionTable results = new DataRegionTable("query", getDriver());
        List<String> expectedColumns = Arrays.asList(
                "Id/birth/species"
                ,"Id"
                ,"Id/demographics/gender"
                ,"Id/age/yearsAndMonthsAndDays"
                ,"Id/MostRecentWeight/MostRecentWeight"
                ,"Id/curLocation/location"
                ,"Id/DemographicsActiveAssignment/primaryProjectDate"
                ,"projectCode"
                ,"assignmentStatus"
                ,"Id/DemographicsActiveAssignment/primaryProject"
                ,"Id/DemographicsActiveAssignment/secondaryProjects"
                ,"Id/DemographicsActivePayor/payor_ids"
                ,"Id/flagList/values"
                ,"Id/DemographicsActiveColony/colonyCode"
                ,"Id/DemographicsActiveBreedingGroup/groupCode"
                ,"Id/DemographicsActivePregnancy/conNum"
                ,"Id/DemographicsActivePregnancy/daysPregnant"
                ,"Id/DemographicsActivePregnancy/conceptionDateStatus"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        int rowIndex = results.getRowIndex(1,"TEST1112911");
        assertEquals("Wrong value for ID: ", "TEST1112911", results.getDataAsText(rowIndex,1));
        assertEquals("Wrong value for Proj Assn Date: ", "2005-05-20", results.getDataAsText(rowIndex,6));
        assertEquals("Wrong value for Searched Project: ", PROJECT_CODE_5_CHAR_1, results.getDataAsText(rowIndex,7));
    }

    @Test
    public void testAnimalHistoryDiarrheaCalendar() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectSingleAnimalSearch().searchFor("TEST6390238");
        animalHistoryPage.clickCategoryTab("Daily Reports");
        animalHistoryPage.clickReportTab("Diarrhea Calendar");

        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                "Id","Year","MonthName","monthNum",
                "1::inds","2::inds","3::inds","4::inds","5::inds","6::inds","7::inds",
                "8::inds","9::inds","10::inds","11::inds","12::inds","13::inds","14::inds",
                "15::inds","16::inds","17::inds","18::inds","19::inds","20::inds",
                "21::inds","22::inds","23::inds","24::inds","25::inds","26::inds",
                "27::inds","28::inds","29::inds","30::inds","31::inds"
        );
        assertEquals("Wrong columns",expectedColumns,results.getColumnNames());

        List<String> expected = Arrays.asList(
                "TEST6390238","2012","January","1","","","Dc","","","Dc","","","Dc","","","Dc","","","","","","Dc","","","Dc","","","Dc","","","Dc","","","Dc",""
        );

        //results.setAsync(true); // setting async governs whether setSort will wait for the menuitem to stale
       // results.setSort("Id", SortDirection.ASC);
        List<String> resultsRowDataAsText = results.getRowDataAsText(0);//.subList(0, expectedColumns.size() - 1);
        assertEquals("Wrong data", expected, resultsRowDataAsText);

        animalHistoryPage.selectSingleAnimalSearch().searchFor("TEST3224553");
        animalHistoryPage.clickCategoryTab("Daily Reports");
        animalHistoryPage.clickReportTab("Diarrhea Calendar");

        List<String> expectedForSecondAnimal = Arrays.asList(
                "TEST3224553","2010","January","1","","","","+","","","","","","","","","","","","","","","~","","","","","","","","","","","","Dc"
        );
        results = animalHistoryPage.getActiveReportDataRegion();
        List<String> resultsRowDataAsTextForSecondAnimal = results.getRowDataAsText(0);
        assertEquals("Wrong data for animal TEST3224553 - row 0",expectedForSecondAnimal,resultsRowDataAsTextForSecondAnimal);

        List<String> expectedForSecondAnimal9 = Arrays.asList(
                "TEST3224553","2011","January","1","","","","","","~","","","","~","","","","","","","","","D","","","","","","","","","","","","Dc"
        );
        resultsRowDataAsTextForSecondAnimal = results.getRowDataAsText(9);
        assertEquals("Wrong data for animal TEST3224553 - row 9",expectedForSecondAnimal9,resultsRowDataAsTextForSecondAnimal);
    }

    @Test
    public void testPedigreeReports() throws Exception
    {
        AnimalHistoryPage<?> animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        String id = "TEST6390238";
        animalHistoryPage.searchSingleAnimal(id);
        animalHistoryPage.clickCategoryTab("Genetics");
        animalHistoryPage.clickReportTab("Pedigree Plot");

        waitForElement(Locator.tagContainingText("span", "Pedigree Plot - " + id), WAIT_FOR_JAVASCRIPT * 3);
        assertTextNotPresent("Error executing command");
        Assert.assertTrue(isTextPresent("Console output"));

        animalHistoryPage.clickReportTab("Pedigree");
        waitForElement(Locator.tagContainingText("span", "Offspring - " + id), WAIT_FOR_JAVASCRIPT * 3);
        waitForElement(Locator.tagContainingText("span", "Siblings - " + id), WAIT_FOR_JAVASCRIPT * 3);
        assertTextPresent("Parents/Grandparents");

        animalHistoryPage.clickCategoryTab("Reproductive Management");
        animalHistoryPage.clickReportTab("Offspring");

        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                "Id","gender","Relationship","Offspring","birth","Sex","Flags","Location","calculated_status","LastKnownLocation","qcstate"
        );
        assertEquals("Wrong columns",expectedColumns,results.getColumnNames());

        List<String> expected = Arrays.asList(
                id,"Male","Offspring","TEST2","2002-10-13","Female","AMC, BETA, CHU","58737393","Alive", "58737393"
        );
        List<String> resultsRowDataAsText = results.getRowDataAsText(0).subList(0, expectedColumns.size() - 1);
        assertEquals("Wrong data", expected, resultsRowDataAsText);

        animalHistoryPage.clickCategoryTab("Reproductive Management");
        animalHistoryPage.clickReportTab("Siblings");

        expectedColumns= Arrays.asList(
                "Id","Relationship","Sibling","Sex","Flags","Location","SiblingDam","SiblingSire","calculated_status","LastKnownLocation","qcstate"
        );
        waitForElement(new Locator.LinkLocator("Siblings - " + id));
        results = animalHistoryPage.getActiveReportDataRegion();
        assertEquals("Wrong columns",expectedColumns,results.getColumnNames());
        assertTextPresent("No data to show");
        assertEquals("Wrong row count",0,results.getDataRowCount());

        id = "TEST3";
        animalHistoryPage.searchSingleAnimal(id);
        waitForElement(new Locator.LinkLocator("Siblings - " + id));
        results = animalHistoryPage.getActiveReportDataRegion();
        expected = Arrays.asList(
                id,"Full Sib","TEST2","Female","AMC, BETA, CHU","58737393","TEST2312318","TEST6390238", "Alive", "58737393"
        );
        resultsRowDataAsText = results.getRowDataAsText(0).subList(0, expectedColumns.size() - 1);
        assertEquals("Wrong row count",10,results.getDataRowCount());
        assertEquals("Wrong data", expected, resultsRowDataAsText);

        animalHistoryPage.clickCategoryTab("Genetics");
        animalHistoryPage.clickReportTab("Kinship");
        waitForText("Kinship - " + id);
        waitForText("Coefficient");
        results = animalHistoryPage.getActiveReportDataRegion();
        expectedColumns= Arrays.asList(
                "Id","Id2","coefficient"
        );
        assertEquals("Wrong columns",expectedColumns,results.getColumnNames());
        expected = Arrays.asList(
                id,"TEST5158984","0.25"
        );
        resultsRowDataAsText = results.getRowDataAsText(0);
        assertEquals("Wrong row count",12,results.getDataRowCount());
        assertEquals("Wrong data", expected, resultsRowDataAsText);

        animalHistoryPage.clickReportTab("Inbreeding Coefficients");
        results = animalHistoryPage.getActiveReportDataRegion();
        expectedColumns= Arrays.asList(
                "Id", "date", "coefficient", "projectCode", "taskid", "requestid", "description", "remark", "history", "QCState"
        );
        assertEquals("Wrong columns",expectedColumns,results.getColumnNames());
    }

    @Test
    public void testAnimalHistoryConceptionHistory() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Reproductive Management");
        animalHistoryPage.clickReportTab("Conception History");

        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                "Id",
                "conNum",
                "femaleSpecies",
                "offspringId",
                "offspringSex/code",
                "conception",
                "BRType",
                "sire",
                "femaleGeneticsVerify",
                "maleGeneticsVerify",
                "gestationDays",
                "conceptionDateStatus",
                "termDate",
                "deliveryType",
                "offspringLocationDate",
                "offspringLocation",
                "deathType",
                "termComment"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

    }

    @Test
    public void testAnimalHistoryProjectAssignmentHistoryView() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Assignments and Groups");
        animalHistoryPage.clickReportTab("Project Assignment History");
        animalHistoryPage.searchSingleAnimal("44444");

        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();

        List<String> expectedColumns = Arrays.asList(
                "Id"
                ,"date"
                ,"enddate"
                ,"projectCode"
                ,"assignmentStatus"
                ,"pi_name"
                ,"title"
                ,"protocol"
                ,"unitCode"
                ,"timeOnProject"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        List<String> expected = Arrays.asList(
                "44444"
                , "2008-09-20"
                , "2016-01-01"
                , PROJECT_CODE_5_CHAR_1
                , "S"
                , PROJECT_INVESTIGATOR_NAME_1
                , " "
                , PROTOCOL_ID_10_CHAR_2
                , UNIT_CODE
                , "07:03:11"
        );

        int rowIndex = results.getRowIndex("projectCode", PROJECT_CODE_5_CHAR_1);

        List<String> resultsRowDataAsText = results.getRowDataAsText(rowIndex);
        assertEquals("Wrong data for row 2.", expected, resultsRowDataAsText);
        assertEquals("Wrong row count: ", 3, results.getDataRowCount());
    }

    @Test
    public void testAnimalHistoryGeneralAndSnapshotReport() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.clickCategoryTab("General");
        animalHistoryPage.clickReportTab("Snapshot");

        log("Checking for acquired animal");
        animalHistoryPage.searchSingleAnimal("TEST1");

        Map<String,String> expectedColumns = new HashMap<String,String>();
        expectedColumns.put("Sex","Female");
        expectedColumns.put("Generation","4");
        expectedColumns.put("Birth","2000-03-28");
        expectedColumns.put("Birth Con No","");
        expectedColumns.put("Dam ID","8416939");
        expectedColumns.put("Sire ID","5030167");
        expectedColumns.put("Acquisition","2005-07-19 abl");
        expectedColumns.put("Previous ID","PREVID");
        expectedColumns.put("Death","");
        expectedColumns.put("Departure","");
        expectedColumns.put("Acquisition Age","05:03:22");
        expectedColumns.put("Time at CNPRC","12:05:02");
        expectedColumns.put("Age at Departure/Death","");
        expectedColumns.put("Location","2004-02-19 58737392");
        expectedColumns.put("Weight","2011-07-22  5.83 kg");
        expectedColumns.put("Body Condition","2011-07-22  5.5");
        expectedColumns.put("TB Test","2010-01-25");
        expectedColumns.put("Serum Bank","2016-09-29");
        expectedColumns.put("Harvest","");
        expectedColumns.put("SPF Status","0 - Conventional");
        expectedColumns.put("Colony","X");
        expectedColumns.put("Breeding group","O");
        expectedColumns.put("Perdiem","2015-05-01  AB125/YZ16");

        WebElement activeReportPanel = animalHistoryPage.getActiveReportPanel();

        List<String> labels = getTexts(Locator.byClass("x4-field-label-cell").findElements(activeReportPanel));
        List<String> values = getTexts(Locator.byClass("x4-field-label-cell").followingSibling("td").findElements(activeReportPanel));
        Iterator<String> ilabels = labels.iterator();
        Iterator<String> ivalues = values.iterator();
        Map<String,String> map = new HashMap<String,String>();
        while (ilabels.hasNext() && ivalues.hasNext())
        {
            expectedColumns.containsKey(ilabels.next());
            expectedColumns.containsValue(ivalues.next());
        }

        assertTextPresent("Last Project(s)");
        assertTextPresent("Census Flag(s)");
        assertTextPresent("Pathology Report(s)");

        log("Checking for dead animal");
        animalHistoryPage.searchSingleAnimal("TEST1");
        List<String> deadLabels = getTexts(Locator.byClass("x4-field-label-cell").findElements(activeReportPanel));
        List<String> deadValues = getTexts(Locator.byClass("x4-field-label-cell").followingSibling("td").findElements(activeReportPanel));
        Map<String,String> expectedColumnsForDead = new HashMap<String,String>();
        expectedColumnsForDead.put("Death","2011-06-06  M  Trauma");
        expectedColumnsForDead.put("Time at CNPRC","01:10:03");
        expectedColumnsForDead.put("Age at Departure/Death","01:10:03");
        expectedColumnsForDead.put("Location","2014-02-19  DEAD from AC500389");

        Iterator<String> ideadLabels = deadLabels.iterator();
        Iterator<String> ideadValues = deadValues.iterator();

        while(ideadLabels.hasNext() && ideadValues.hasNext())
        {
            expectedColumnsForDead.containsValue(ideadValues.next());
            expectedColumnsForDead.containsKey(ideadLabels.next());
        }

    }
    @Test
    public void testAnimalHistoryImmunizationView() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Clinical");
        String reportTab = "Immunizations";
        animalHistoryPage.clickReportTab(reportTab);
        waitForElement(Locator.linkContainingText(reportTab));
        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                 "Id"
                ,"date"
                ,"code"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        List<String> expected = Arrays.asList(
                "TEST3804589"
                , "2015-04-21 00:00"
                , "T"
        );

        List<String> resultsRowDataAsText = results.getRowDataAsText(0).subList(0, expectedColumns.size());
        assertEquals("Wrong data for row 1.", expected, resultsRowDataAsText);
        assertEquals("Wrong row count: ", 4, results.getDataRowCount());
        assertTextPresent("Legend", "Equine tetanus");

        click(results.link(3, "Vaccine")); // click the 'x' link in the Vaccine column
        switchToWindow(1);
        assertTextPresent("Record Details","Experimental");
    }

    @Test
    public void testAnimalHistoryVirologyView() throws Exception
    {
        storeTestTypeMappingData();

        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Lab Results");
        String reportTab = "Virology";
        animalHistoryPage.clickReportTab(reportTab);
        waitForElement(Locator.linkContainingText(reportTab));
        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                "Id"
                ,"sampleDate"
                ,"testDoneDate"
                ,"virus"
                ,"target"
                ,"method"
                ,"results"
                ,"sampleType"        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        List<String> expected = Arrays.asList(
                "TEST3804589","2016-06-01 13:29","2016-06-29 00:00","CMV","AB","EL","-","SER"
        );

        List<String> resultsRowDataAsText = results.getRowDataAsText(0).subList(0, expectedColumns.size());
        assertEquals("Wrong data for row 1.", expected, resultsRowDataAsText);
        assertEquals("Wrong row count: ", 1, results.getDataRowCount());
        assertTextPresent("Legend", "Virus","Positive");

    }

    @Test
    public void testAnimalHistoryAssignmentHistoryView() throws Exception
    {

        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.searchSingleAnimal("44446");
        animalHistoryPage.clickCategoryTab("Assignments and Groups");
        String reportTab = "Assignment History";
        animalHistoryPage.clickReportTab(reportTab);
        waitForElement(Locator.linkContainingText(reportTab));
        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                "Id"
                ,"assigned"
                ,"released"
                ,"payorId"
                ,"primaryProject"
                ,"secondaryProjects"
                ,"colonyCode"
                ,"groupCode"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        assertEquals("Wrong row count: ", 1, results.getDataRowCount());

        List<String> expected = Arrays.asList("44446","2016-10-05"," ","AB126/YZ18","Pc5C2"," ","X","T");
        confirmRowText(results, expected, 0);

        animalHistoryPage.searchSingleAnimal("44444");
        waitForElement(Locator.linkContainingText(reportTab));
        results = animalHistoryPage.getActiveReportDataRegion();

        expected = Arrays.asList("44444","2014-02-08","2016-01-01","AB125/YZ17","Pc5C0","Pc5C1, Pc5C2","O","M");
        confirmRowText(results, expected, 0);

        assertElementPresent(Locator.linkWithText("AB125/YZ17"));

        // TODO: 4/26/2017 Add tests for Primary and Secondary project look ups.

    }

    private void confirmRowText(DataRegionTable results, List<String> expected, int row)
    {
        List<String> resultsRowDataAsText = results.getRowDataAsText(row);
        assertEquals("Wrong data for row " + row, expected, resultsRowDataAsText);
    }

    private void createPDLLinkedSchema()
    {
        String sourceFolder = "/" + FOLDER_NAME + "/" + COREFACILITIES + "/" + PDLFOLDER;
        _schemaHelper.createLinkedSchema(getProjectName(), null,
                "cnprc_pdl_linked", sourceFolder, null, SCHEMA_CNPRC_PDL,
                null, null);
    }

    private void createBillingLinkedSchema()
    {
        String sourceFolder = "/" + FOLDER_NAME + "/" + COREFACILITIES + "/" + BILLINGFOLDER;
        _schemaHelper.createLinkedSchema(getProjectName(), null,
                "cnprc_billing_linked", sourceFolder, null, SCHEMA_CNPRC_BILLING,
                null, null);
    }

    @Test
    public void testAnimalHistoryPairingHistoryView() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Behavior");
        String reportTab = "Pairing History";
        animalHistoryPage.clickReportTab(reportTab);
        waitForElement(Locator.linkContainingText(reportTab));

        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumns = Arrays.asList(
                 "Id"
                ,"pairedWithId"
                ,"date"
                ,"endDate"
                ,"observation"
                ,"remark"
                ,"timePaired"
        );
        assertEquals("Wrong columns", expectedColumns, results.getColumnNames());

        List<String> expected = Arrays.asList(
                "TEST1112911"
                ,"TEST1684145"
                ,"2011-07-19 11:29"
                ," "
                ,"IP"
        );

        List<String> resultsRowDataAsText = results.getRowDataAsText(0).subList(0, 5);
        assertEquals("Wrong data for row 1.", expected, resultsRowDataAsText);
        assertEquals("Wrong row count: ", 12, results.getDataRowCount());

        assertElementPresent(Locator.linkContainingText("TEST1684145"));
        assertTextPresent("Legend", "Pairing Codes", "Deferment Status Codes");

        click(Locator.linkContainingText("IP"));
        switchToWindow(1);
        waitForText("Record Details",
                "Description:",
                "Intermittent pair");
    }

    @Test
    public void testWeightTBandBCSView() throws Exception
    {
        final String animalId = "TEST4564246";
        insertWeightAndTBfor(animalId);
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.searchSingleAnimal(animalId);
        animalHistoryPage.clickCategoryTab("General");
        animalHistoryPage.clickReportTab("Weight, TB, BCS");

        DataRegionTable results = animalHistoryPage.getActiveReportDataRegion();
        List<String> expectedColumnNames = Arrays.asList(
                "id"
                ,"date"
                ,"weight"
                ,"TB"
                ,"test1"
                ,"test2"
                ,"weightTattooFlag"
                ,"bodyConditionScore"
                ,"location"
                ,"cage"
                ,"conception"
                ,"daysPregnant"
        );
        List<String> expectedColumnLabels = Arrays.asList(
                "Animal ID"
                ,"Date"
                ,"Weight (kg)"
                ,"TB"
                ,"Test1"
                ,"Test2"
                ,"Tattoo"
                ,"Body Condition"
                ,"Location"
                ,"Cage"
                ,"Conception"
                ,"Days Pregnant"
        );

        assertEquals("Wrong columns", expectedColumnNames, results.getColumnNames());
        assertEquals("Wrong column labels", expectedColumnLabels, results.getColumnLabels());
        assertEquals("Wrong value for ID: ", animalId, results.getDataAsText(0,0));
        assertEquals("Wrong value for Weight: ", "2.90", results.getDataAsText(0,2));
        assertEquals("Wrong value for TB: ", "TB", results.getDataAsText(0,3));
        assertEquals("Wrong value for Test1: ", "typesite244872", results.getDataAsText(0,4));
        assertEquals("Wrong value for Test2: ", "type2site2244872", results.getDataAsText(0,5));
        assertEquals("Wrong value for Tattoo: ", "X", results.getDataAsText(0,6));
        assertEquals("Wrong value for BCS: ", "3.0", results.getDataAsText(0,7));
        assertEquals("Wrong value for Room: ", "<6824778>", results.getDataAsText(0,8));
        assertEquals("Wrong value for Cage: ", "4953547", results.getDataAsText(0,9));

        List<WebPartPanel> reportPanels = WebPartPanel.WebPart(getDriver()).findAll(animalHistoryPage.getActiveReportPanel());
        List<String> reportTitles = new ArrayList<>();
        reportPanels.forEach(p -> reportTitles.add(p.getTitle()));
        assertEquals("Wrong order for report segments",
                Arrays.asList("Weight Overview: " + animalId, "Weight, TB and Body Condition: " + animalId),
                reportTitles);
    }

    @Test
    public void testAnimalSearchPayorView() throws Exception
    {
        AnimalHistoryPage animalHistoryPage = CNPRCAnimalHistoryPage.beginAt(this);
        animalHistoryPage.selectEntireDatabaseSearch();
        animalHistoryPage.clickCategoryTab("Assignments and Groups");
        animalHistoryPage.clickReportTab("Per-diem Payor Assignment");
        WebElement link = Locator.linkContainingText("AB123/YZ12").findElement(getDriver());
        scrollIntoView(link, true);
        link.click();

        switchToWindow(1);

        DataRegionTable results = new DataRegionTable("query", getDriver());
        List<String> expectedColumns = Arrays.asList(
                "Id/birth/species",
                "Id",
                "Id/demographics/gender/code",
                "Id/age/yearsAndMonthsAndDays",
                "Id/MostRecentWeight/MostRecentWeight",
                "Id/curLocation/location",
                "Id/DemographicsActiveAssignment/primaryProject",
                "Id/DemographicsActiveAssignment/secondaryProjects",
                "Id/DemographicsActivePayor/currentPayorDate",
                "payor_id",
                "Id/DemographicsActivePayor/payor_ids",
                "Id/flagList/values",
                "Id/DemographicsActivePregnancy/conNum",
                "Id/DemographicsActivePregnancy/daysPregnant",
                "Id/DemographicsActiveColony/colonyCode",
                "Id/DemographicsActiveBreedingGroup/groupCode"
        );
        assertEquals("Wrong columns:\n", expectedColumns, results.getColumnNames());

        assertEquals("Wrong value for ID: ", "TEST3804589", results.getDataAsText(0,1));
        assertEquals("Wrong value for Gender: ", "F", results.getDataAsText(0,2));
        assertElementPresent(Locator.linkWithText(PROJECT_CODE_5_CHAR_1));
    }

    @Test
    public void testAnimalSearch() throws Exception
    {
        SearchPanel searchPanel;
        DataRegionTable searchResults;

        searchPanel = getSearchPanel();
        List<String> expectedLabels = Arrays.asList(
                "Species code (3 char):"
                ,"Sex:"
                ,"Status:"
                ,"Pairing Status:"
                ,"Age (Years):"
                ,"Age (Years):"
                ,"Current Weight (kg):"
                ,"Area:"
                ,"Room:"
                ,"Cage:"
                ,"Current Project:"
                ,"Past Projects:"
                ,"Past Projects:"
                ,"Payor Id:"
                ,"Census Flags:"
                ,"Census Flags:"
                ,"Breeding Group:"
                ,"Conception Num:"
                ,"Colony Code:"
                ,"SNOMED:"
                ,"TB Date:"
                ,"SPF Status:"
                ,"Body Condition:"
                ,"View:"
        );

        assertEquals("Wrong search criteria.", expectedLabels, searchPanel.getAllSearchCriteria());
        searchPanel.selectValues("Sex", " All");
        assertEquals("Selecting 'All' genders didn't set input correctly", "Female;Male;Unknown", getFormElement(Locator.input("gender")));
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows for searching all genders", 39, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.selectValues("Species code (3 char)", "CMO");
        assertEquals("Select 'CMO' species didn't set input correctly", "CMO", getFormElement(Locator.input("species")));
        searchPanel.selectValues("Species code (3 char)", "MMU");
        assertEquals("Adding 'MMU' to species filter didn't set input correctly", "CMO;MMU", getFormElement(Locator.input("species")));
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows: Species = CMO or PCY", 39, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.setInput("Id/DemographicsActivePairing/observations", "IP");
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows: Pairing Status = Continuous pair with grate or Intermittent pair",
                3, searchResults.getDataRowCount());
    }

    @NotNull
    private SearchPanel getSearchPanel()
    {
        SearchPanel searchPanel;
        beginAt("/project/" + getContainerPath() + "/begin.view");
        waitAndClickAndWait(Locator.linkWithText("Animal Search"));
        searchPanel = new AnimalSearchPanel(getDriver());
        return searchPanel;
    }

    private void validateLookupFromList(String list, String linkText, String expectedText)
    {
        beginAtPdlListView();
        clickAndWait(Locator.linkContainingText(list));
        clickAndWait(Locator.linkContainingText(linkText));
        assertTextPresent(expectedText);
    }

    private void beginAtPdlListView()
    {
        beginAt(PROJECT_NAME+ "/"  + COREFACILITIES + "/" + PDLFOLDER + "/list-begin.view?");
    }

    private void validateLookupFromTable(String table, String linkText, String expectedText) throws InterruptedException
    {
        beginAtPdlTableView(table);
        clickAndWait(Locator.linkContainingText(linkText));
        waitForText(expectedText);
    }

    private void beginAtPdlTableView(String table)
    {
        beginAt("/query/" + PROJECT_NAME+ "/"  + COREFACILITIES + "/" + PDLFOLDER + "/executeQuery.view?query.queryName=" + table + "&schemaName=cnprc_pdl");
    }

    private void storePDLData() throws Exception
    {
        Connection connection = createDefaultConnection(true);
        String folder = "/" + COREFACILITIES + "/" + PDLFOLDER;
        insertTsvData(connection, SCHEMA_CNPRC_PDL, "samples", PDL_SAMPLE_TSV, folder);
        insertTsvData(connection, SCHEMA_CNPRC_PDL, "sub_tests", PDL_SUB_TEST_TSV, folder);
        insertTsvData(connection, SCHEMA_CNPRC_PDL, "tests",PDL_TEST_TSV, folder);
        insertTsvData(connection, SCHEMA_CNPRC_PDL, "orders", PDL_ORDER_TSV, folder);
    }

    private void storeBillingData() throws Exception
    {
        Connection connection = createDefaultConnection(true);
        String folder = "/" + COREFACILITIES + "/" + BILLINGFOLDER;
        insertTsvData(connection, SCHEMA_CNPRC_BILLING, "account", BILLING_ACCOUNT_TSV, folder);
    }

    private void insertTsvData(Connection connection, String schemaName, String queryName, File tsvFile, @Nullable String folder)
            throws java.io.IOException, org.labkey.remoteapi.CommandException
    {
        InsertRowsCommand command = new InsertRowsCommand(schemaName, queryName);
        List<Map<String, Object>> tsv = loadTsv(tsvFile);
        command.setRows(tsv);
        command.execute(connection, getProjectName() + folder);
    }

    //TODO: Blocked tests from AbstractGenericEHRTest. Remove once more features are added.

    @Override @Ignore
    public void customActionsTest()
    {
    }

    @Override @Ignore
    public void testQuickSearch()
    {
    }

    @Override @Ignore
    public void testWeightValidation() throws Exception
    {
    }

    @Override @Ignore
    public void testSecurityDataAdmin() throws Exception
    {
    }

    @Override @Ignore
    public void testSecurityRequester() throws Exception
    {
    }

    @Override @Ignore
    public void testSecurityBasicSubmitter() throws Exception
    {
    }

    @Override @Ignore
    public void testSecurityFullSubmitter() throws Exception
    {
    }

    @Override @Ignore
    public void testSecurityFullUpdater() throws Exception
    {
    }

    @Override @Ignore
    public void testSecurityRequestAdmin() throws Exception
    {
    }

    @Override @Ignore
    public void testCustomButtons()
    {
    }

    @Override @Ignore
    public void testCalculatedAgeColumns()
    {
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }
}