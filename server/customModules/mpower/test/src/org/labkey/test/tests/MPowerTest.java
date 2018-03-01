/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
package org.labkey.test.tests;

import org.jetbrains.annotations.Nullable;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.RemoteConnectionHelper;
import org.labkey.test.util.WikiHelper;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.fail;

@Category({CustomModules.class})
public class MPowerTest extends BaseWebDriverTest
{
    private static final String SECURE_PROJECT_NAME = "MPowerTest Secure Project";
    private static final String MPOWER_SECURE_USER = "secure-test-submitter@mpower.org";
    private static final String MPOWER_SECURE_USER_PASSWORD = "mpower";
    private static final String MPOWER_SECURE_SUBMITTER_ROLE = "MPower Secure Submitter";
    private static final String REMOTE_SOURCE_NAME = "mpower-remote-source";
    private static final String SURVEY_COMPLETION_TEXT = "Thank You for Participating in the Survey";

    @Nullable
    @Override
    protected String getProjectName()
    {
        return getClass().getSimpleName() + "Test Project";
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("mpower");
    }

    @Override
    protected BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @BeforeClass
    public static void initTest()
    {
        MPowerTest init = (MPowerTest)getCurrentTest();
        init.doSetup();
    }

    private void doSetup()
    {
        enableEmailRecorder();

        // setup the private server project
        log("Setting up the secure server project");
        _containerHelper.createProject(SECURE_PROJECT_NAME, null);
        _containerHelper.enableModule("MPower");
        _userHelper.createUserAndNotify(MPOWER_SECURE_USER);
        setInitialPassword(MPOWER_SECURE_USER, MPOWER_SECURE_USER_PASSWORD);
        ensureSignedInAsPrimaryTestUser();
        goToProjectHome(SECURE_PROJECT_NAME);
        _permissionsHelper.setUserPermissions(MPOWER_SECURE_USER, MPOWER_SECURE_SUBMITTER_ROLE);

        // setup the public server project
        log("Setting up the public server project");
        _containerHelper.createProject(getProjectName(), null);
        _containerHelper.enableModule("MPower");

        RemoteConnectionHelper helper = new RemoteConnectionHelper(this);
        helper.createConnection(REMOTE_SOURCE_NAME, getBaseURL(), SECURE_PROJECT_NAME + '/', MPOWER_SECURE_USER, MPOWER_SECURE_USER_PASSWORD);

        // create the temporary wiki landing page after survey completion
        goToProjectHome();
        WikiHelper wikiHelper = new WikiHelper(this);
        goToModule("Wiki");
        wikiHelper.createWikiPage("mpowersurveycomplete", null, SURVEY_COMPLETION_TEXT, "Thanks", false, null, false);
    }

    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        deleteUsersIfPresent(MPOWER_SECURE_USER);
        _containerHelper.deleteProject(SECURE_PROJECT_NAME, false);

        super.doCleanup(afterTest);
    }

    @Test
    public void testPatientCharacteristics()
    {
        startSurvey("Randy", "Jones", "1940", "June", "15");
        String token = getUrlParam("token", false);

        assertTextPresent("The goal of the M POWER project");
        clickButton("Next", "Patient Characteristics");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Have you been diagnosed with prostate cancer?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Yes, within the past year");

        _ext4Helper.selectComboBoxItem(Locators.monthComboBox(), "April");
        _ext4Helper.selectComboBoxItem(Locators.dayComboBox(), "15");
        _ext4Helper.selectComboBoxItem(Locators.yearComboBox(), "1950");

        _ext4Helper.checkCheckbox("White");
        _ext4Helper.checkCheckbox("Black or African American");

        _ext4Helper.selectRadioButton("College graduate");
        _ext4Helper.selectRadioButton("Divorced");
        _ext4Helper.selectRadioButton("Unemployed");

        _ext4Helper.checkCheckbox("Commercial");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("What is your current plan?:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Group Health Cooperative");

                click(Locators.surveySidebarLink("Save / Cancel"));
        sleep(500);
        clickButton("Save", 0);
        waitForText(SURVEY_COMPLETION_TEXT);

        log("Verifying patient characteristics responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        Map<String, String> row = new HashMap<>();
        row.put("PatientId", token);
        row.put("DiagnosisStatus", "Yes, within the past year");
        row.put("RaceWhite", "true");
        row.put("RaceBlack", "true");
        row.put("EducationLevel", "College graduate");
        row.put("MaritalStatus", "Divorced");
        row.put("EmploymentStatus", "Unemployed");

        // verify the inserted row via the data region table
        verifyDataRegionRows("PatientDemographics", Collections.singletonList(row), "PatientId");

        row = new HashMap<>();
        row.put("PatientId", token);
        row.put("Name", "Group Health Cooperative");
        row.put("Commercial", "true");
        row.put("Military", "false");

        // verify the inserted row via the data region table
        verifyDataRegionRows("Insurance", Collections.singletonList(row), "PatientId");
    }

    @Test
    public void testClinicalDiagnosis()
    {
        startSurvey("Bobby", "Jones", "1943", "September", "11");
        String token = getUrlParam("token", false);

        assertTextPresent("The goal of the M POWER project");
        click(Locators.surveySidebarLink("Clinical Diagnosis"));

        _ext4Helper.selectRadioButton("10-20 ng/mL");
        _ext4Helper.selectRadioButton("Cancer is found in the prostate only");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Have you ever had a genetic/ genomic test on your blood or tumor?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Not sure");

        click(Locators.surveySidebarLink("Save / Cancel"));
        sleep(500);
        clickButton("Save", 0);
        waitForText(SURVEY_COMPLETION_TEXT);

        log("Verifying clinical diagnosis responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        Map<String, String> row = new HashMap<>();
        row.put("PatientId", token);
        row.put("PSALevel", "10-20 ng/mL");
        row.put("CancerExtent", "Cancer is found in the prostate only");
        row.put("GeneticTest", "Not sure");

        // verify the inserted row via the data region table
        verifyDataRegionRows("ClinicalDiagnosis", Collections.singletonList(row), "PatientId");
    }

    @Test
    public void testFamilyHistory()
    {
        startSurvey("Peter", "Meyers", "1981", "May", "3");

        assertTextPresent("The goal of the M POWER project");
        click(Locators.surveySidebarLink("Family History of Prostate Cancer"));

        _ext4Helper.checkCheckbox("Children");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("How old were they when they were diagnosed?:", 2),
                Ext4Helper.TextMatchTechnique.CONTAINS, "18-40");
        _ext4Helper.checkCheckbox("Father");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("How old were they when they were diagnosed?:", 6),
                Ext4Helper.TextMatchTechnique.CONTAINS, "60+");

        _ext4Helper.checkCheckbox("Sister (full, half)");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Where did the cancer start?:", 1),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Brain");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("How old were they when they were diagnosed?:", 11),
                Ext4Helper.TextMatchTechnique.CONTAINS, "40-60");

        // verify we can still submit with an incomplete response
        _ext4Helper.checkCheckbox("Mother");

        click(Locators.surveySidebarLink("Save / Cancel"));
        sleep(500);
        clickButton("Save", 0);
        waitForText(SURVEY_COMPLETION_TEXT);

        log("Verifying family history responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        goToSchemaBrowser();
        selectQuery("mpower", "FamilyHistory");
        waitForText("view data");
        clickAndWait(Locator.linkContainingText("view data"));
        DataRegionTable drt = new DataRegionTable("query", this);

        assertEquals("Number of family members didn't match", 2, drt.getDataRowCount());
    }

    @Test
    public void testTreatment()
    {
        startSurvey("Mike", "Smith", "1942", "March", "30");
        String token = getUrlParam("token", false);

        assertTextPresent("The goal of the M POWER project");
        click(Locators.surveySidebarLink("Treatment"));

        _ext4Helper.selectRadioButton("I had treatment for my prostate cancer and I am being treated because my PSA was rising");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Did you have active treatment for your prostate cancer within one year after your original diagnosis?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Yes");
        _ext4Helper.selectRadioButton("Doctor (Surgeon)");
        _ext4Helper.checkCheckbox("Active surveillance");

        // verify treatment types persistence is more lenient, if not all information is specified we won't save it but
        // the survey won't error out
        _ext4Helper.checkCheckbox("Surgery");
        _ext4Helper.checkCheckbox("Orchiectomy (testicle removal)");
        _ext4Helper.checkCheckbox("Other surgery");

        _ext4Helper.checkCheckbox("Radiation");
        _ext4Helper.checkCheckbox("Cyberknife");

        _ext4Helper.checkCheckbox("Medical Treatment");
        _ext4Helper.checkCheckbox("Chemotherapy (docetaxel)");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Has your prostate cancer spread outside of the prostate?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Yes");
        _ext4Helper.checkCheckbox("Lymph nodes");
        _ext4Helper.checkCheckbox("Bones");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Overall, how satisfied are you with the treatment(s) you received for your prostate cancer?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Satisfied");

        click(Locators.surveySidebarLink("Save / Cancel"));
        sleep(500);
        clickButton("Save", 0);
        waitForText(SURVEY_COMPLETION_TEXT);

        log("Verifying treatment responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        Map<String, String> row = new HashMap<>();
        row.put("PatientId", token);
        row.put("CurrentTreatmentState", "I had treatment for my prostate cancer and I am being treated because my PSA was rising");
        row.put("TreatmentWithinYear", "true");
        row.put("PrimaryClinician", "Doctor (Surgeon)");
        row.put("TreatmentWithinYear", "true");
        row.put("CancerSpreadBeyondProstate", "true");
        row.put("SpreadToLymphs", "true");
        row.put("SpreadToBones", "true");
        row.put("SpreadToOrgans", "false");
        row.put("TreatmentSatisfaction", "Satisfied");

                // verify the inserted row via the data region table
        verifyDataRegionRows("Treatment", Collections.singletonList(row), "PatientId");

        log("Verifying treatment type responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        row = new HashMap<>();
        row.put("PatientId", token);
        row.put("Name", "Active surveillance");
        row.put("Surgery", "false");
        row.put("Radiation", "false");

        // verify the inserted row via the data region table
        verifyDataRegionRows("TreatmentType", Collections.singletonList(row), "PatientId");
    }

    @Test
    public void testQualityOfLife()
    {
        startSurvey("Fred", "Baker", "1925", "March", "3");
        String token = getUrlParam("token", false);

        assertTextPresent("The goal of the M POWER project");
        click(Locators.surveySidebarLink("Quality of Life"));

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Over the past 4 weeks, how often have you leaked urine?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "About once a day");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Which of the following best describes your urinary control during the last 4 weeks?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Frequent dribbling");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("How many pads or adult diapers per day did you usually use to control leakage during the last 4 weeks?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "1 pad per day");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Urgency to have a bowel movement:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Small problem");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Increased frequency of bowel movements:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Moderate problem");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Losing control of your stools:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Big problem");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Hot flashes:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Very small problem");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Feeling depressed:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Moderate problem");
        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Lack of energy:"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "No problem");

        click(Locators.surveySidebarLink("Save / Cancel"));
        sleep(500);
        clickButton("Save", 0);
        waitForText(SURVEY_COMPLETION_TEXT);

        log("Verifying quality of life responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        Map<String, String> row = new HashMap<>();
        row.put("PatientId", token);
        row.put("FourWeekFrequencyUrineLeaking", "About once a day");
        row.put("FourWeekUrineControl", "Frequent dribbling");
        row.put("FourWeekDiaperUse", "1 pad per day");
        row.put("ProblemBowelUrgency", "Small problem");
        row.put("ProblemBowelFrequency", "Moderate problem");
        row.put("ProblemStoolControl", "Big problem");
        row.put("FourWeekProblemHotFlash", "Very small problem");
        row.put("FourWeekProblemDepression", "Moderate problem");
        row.put("FourWeekProblemEnergy", "No problem");

        // verify the inserted row via the data region table
        verifyDataRegionRows("LifeQuality", Collections.singletonList(row), "PatientId");
    }

    @Test
    public void testLifestyle()
    {
        startSurvey("Jerry", "Hall", "1963", "July", "9");
        String token = getUrlParam("token", false);

        assertTextPresent("The goal of the M POWER project");
        click(Locators.surveySidebarLink("Lifestyle"));

        _ext4Helper.checkCheckbox("Osteoporosis");
        _ext4Helper.checkCheckbox("Congestive heart failure (or heart disease)");
        _ext4Helper.checkCheckbox("Peripheral vascular disease");

        _ext4Helper.checkCheckbox("Homeopathy");
        _ext4Helper.checkCheckbox("Mental health counseling or psychotherapy");
        _ext4Helper.checkCheckbox("Personal Prayer");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Do you smoke cigarettes?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Yes");
        setFormElement(Locator.name("CigarettesPerDayBeforeDiagnosis"), "10");
        setFormElement(Locator.name("CigarettesPerDayCurrently"), "5");

        _ext4Helper.selectComboBoxItem(Locators.surveyCombobox("Have you ever attended a prostate support group?"),
                Ext4Helper.TextMatchTechnique.CONTAINS, "Yes, one meeting");

        click(Locators.surveySidebarLink("Save / Cancel"));
        sleep(500);
        clickButton("Save", 0);
        waitForText(SURVEY_COMPLETION_TEXT);

        log("Verifying lifestyle responses");
        goToProjectHome(SECURE_PROJECT_NAME);
        Map<String, String> row = new HashMap<>();
        row.put("PatientId", token);
        row.put("AlternateTherapyHomeopathy", "true");
        row.put("AlternateTherapyPsychotherapy", "true");
        row.put("AlternateTherapyPrayer", "true");
        row.put("Cigarettes", "true");
        row.put("CigarettesPerDayBeforeDiagnosis", "10");
        row.put("CigarettesPerDayCurrently", "5");
        row.put("AttendedProstateSupportGroup", "Yes, one meeting");

        // verify the inserted row via the data region table
        verifyDataRegionRows("Lifestyle", Collections.singletonList(row), "PatientId");

        log("verifying medical condition");
        goToSchemaBrowser();
        selectQuery("mpower", "MedicalCondition");
        waitForText("view data");
        clickAndWait(Locator.linkContainingText("view data"));
        DataRegionTable drt = new DataRegionTable("query", this);

        assertEquals("Number of medical condition records didn't match", 3, drt.getDataRowCount());
    }

    @Test
    public void testConsentPage() throws Exception
    {
        startSurvey("Bob", "Smith", "1950", "April", "15");
        log("Ensure token validation");

        // ensure that the page doesn't render if the token is invalid
        beginAt(getCurrentRelativeURL() + "7b");
        assertTextPresent("An Invalid User Token was Specified");
    }

    @Test
    public void testUserReenterSurvey()
    {
        // we've already seen this user but it should be okay
        startSurvey("Randy", "Jones", "1940", "June", "15");
    }

    private void verifyDataRegionRows(String tableName, List<Map<String, String>> expectedRows, String key)
    {
        log("verifying mpower data rows in the schema browser");
        goToSchemaBrowser();
        selectQuery("mpower", tableName);
        waitForText("view data");
        clickAndWait(Locator.linkContainingText("view data"));
        DataRegionTable drt = new DataRegionTable("query", this);

        // find the row to verify
        for (Map<String, String> expectedRow : expectedRows)
        {
            String expectedKeyValue = expectedRow.get(key);
            if (expectedKeyValue != null)
            {
                int idx = drt.getRow(key, expectedKeyValue);
                if (idx == -1)
                    idx = drt.getRow(key, expectedKeyValue.toUpperCase());
                if (idx == -1)
                    idx = drt.getRow(key, expectedKeyValue.toLowerCase());
                assertNotEquals(String.format("Didn't find row with %s = %s", key, expectedKeyValue), idx, -1);

                Map<String, String> actualRow = new HashMap<>();
                for (Map.Entry<String, String> field : expectedRow.entrySet())
                {
                    actualRow.put(field.getKey(), drt.getDataAsText(idx, field.getKey()));
                }

                // don't need to test that the key value matches
                expectedRow.remove(key);
                actualRow.remove(key);

                assertEquals("Bad row data", expectedRow, actualRow);
            }
            else
            {
                fail("verifyDataRegionRows: Unable to find key value : " + key);
            }
        }
    }

    private void startSurvey(String firstName, String lastName, String year, String month, String day)
    {
        log("Navigate to the consent page");

        beginAt(WebTestHelper.buildURL("mpower", getProjectName(), "begin"));
        waitForElement(Locator.name("firstName"));
        setFormElement(Locator.name("firstName"), firstName);
        setFormElement(Locator.name("lastName"), lastName);
        setFormElement(Locator.name("signature"), firstName + " " + lastName);

        setDate(year, month, day);
        clickButton("Next");

        _ext4Helper.waitForMaskToDisappear();
    }

    private void setDate(String year, String month, String day)
    {
        waitForElement(Locators.monthComboBox());
        waitForElement(Locators.dayComboBox());
        waitForElement(Locators.yearComboBox());
        _ext4Helper.selectComboBoxItem(Locators.monthComboBox(), month);
        _ext4Helper.selectComboBoxItem(Locators.dayComboBox(), day);
        _ext4Helper.selectComboBoxItem(Locators.yearComboBox(), year);
    }

    static class Locators
    {
        public static Locator.XPathLocator monthComboBox()
        {
            return Locator.tagWithClass("table", "mpower-month-combo").append("//tbody");
        }

        public static Locator.XPathLocator dayComboBox()
        {
            return Locator.tagWithClass("table", "mpower-day-combo").append("//tbody");
        }

        public static Locator.XPathLocator yearComboBox()
        {
            return Locator.tagWithClass("table", "mpower-year-combo").append("//tbody");
        }

        public static Locator.XPathLocator surveySidebarLink(String name)
        {
            return Locator.tagWithClass("li", "labkey-side-bar-title").withText(name);
        }

        public static Locator.XPathLocator surveyCombobox(String label)
        {
            return Locator.xpath("//tbody[./tr/td/label[text()='" + label + "']]");
        }

        public static Locator.XPathLocator surveyCombobox(String label, int index)
        {
            return Locator.xpath("(//tbody[./tr/td/label[text()='" + label + "']])[" + index + "]");
        }
    }
}
