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
package org.labkey.test.tests.adjudication;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.SortDirection;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.components.adjudication.AdjudicationDeterminationForm;
import org.labkey.test.components.adjudication.AdjudicationDeterminationForm.HivStatus;
import org.labkey.test.components.adjudication.AdjudicatorTeamMemberForm;
import org.labkey.test.components.adjudication.AdministratorDashboard;
import org.labkey.test.components.adjudication.Notifications;
import org.labkey.test.components.dumbster.EmailRecordTable;
import org.labkey.test.components.ext4.Checkbox;
import org.labkey.test.components.ext4.Window;
import org.labkey.test.pages.adjudication.AdjudicationDeterminationPage;
import org.labkey.test.pages.adjudication.AdjudicationPage;
import org.labkey.test.pages.adjudication.AdminReviewAdjudicationsPage;
import org.labkey.test.pages.adjudication.AdministratorDashboardPage;
import org.labkey.test.pages.adjudication.InfectionMonitorPage;
import org.labkey.test.pages.adjudication.UploadWizard;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.openqa.selenium.NoSuchElementException;

import java.io.File;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

@Category({CustomModules.class})
public class AdjudicationTest extends AdjudicationAbstractBaseTest
{
    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        _containerHelper.deleteProject(getProjectName(), afterTest);
        _userHelper.deleteUsers(afterTest,
                USER_READER1,
                USER_READER2,
                USER_READER3,
                USER_LAB_PERSONNEL,
                USER_INF_MONITOR,
                USER_DATA_REVIEWER,
                USER_ADJUDICATOR1,
                USER_ADJUDICATOR2,
                USER_ADJUDICATOR3,
                USER_ADJUDICATOR4);
    }

    @BeforeClass
    public static void setupProject()
    {
        AdjudicationTest init = (AdjudicationTest) getCurrentTest();

        init.doSetup();
    }

    private void doSetup()
    {
        _userHelper.createUser(USER_READER1);
        _userHelper.createUser(USER_READER2);
        _userHelper.createUser(USER_READER3);
        _userHelper.createUser(USER_LAB_PERSONNEL);
        _userHelper.createUser(USER_INF_MONITOR);
        _userHelper.createUser(USER_DATA_REVIEWER);
        _userHelper.createUser(USER_ADJUDICATOR1);
        _userHelper.createUser(USER_ADJUDICATOR2);
        _userHelper.createUser(USER_ADJUDICATOR3);
        _userHelper.createUser(USER_ADJUDICATOR4);

        String[] usersReaders = {USER_READER1, USER_READER2};
        String[] adjudicationUsers = {
            getCurrentUser() + ";" + ROLE_FOLDER_ADMIN,
            USER_LAB_PERSONNEL + ";" + ROLE_LAB_PERSONNEL,
            USER_INF_MONITOR + ";" + ROLE_INF_MONITOR,
            USER_DATA_REVIEWER + ";" + ROLE_DATA_REVIEWER,
            USER_ADJUDICATOR1 + ";" + ROLE_ADJUDICATOR + ";1",
            USER_ADJUDICATOR2 + ";" + ROLE_ADJUDICATOR + ";2"
        };
        String[] assayResultFields = {
                "Band-Foo1;Band Foo 1"
        };

        _adjTestSupport.createAdjudicationProject(getProjectName(), usersReaders, adjudicationUsers, null, "VTN703", "Both HIV-1 and HIV-2", assayResultFields);

        _adjTestSupport.insertAssayKits();
        _adjTestSupport.addDefaultAssayTypes();
    }

    @Before
    public void preTest()
    {
        enableEmailRecorder(); // this should reset the dumbster list for each test case
        goToProjectHome();
    }

    @Test
    public void testCaseUpload()
    {
        final String caseComment = "testCaseUpload comment " + BaseWebDriverTest.TRICKY_CHARACTERS;

        impersonate(USER_LAB_PERSONNEL);
        UploadWizard uploadWizard = UploadWizard.beginAt(this, getProjectName());
        UploadWizard.Step1 step1 = uploadWizard.startWizard();
        assertEquals("Wrong number of data rows", 4, step1.uploadDataFile(CASE1_FILE));
        UploadWizard.Step2 step2 = step1.clickNext();
        assertEquals("Wrong ptid", CASE1_PTID, step2.getPtid());
        assertEquals("Wrong visits", CASE1_VISITS, step2.getVisits());
        step2.setCaseComment(caseComment);
        UploadWizard.Step3 step3 = step2.clickNext();
        step3.uploadOptionalFile(CASE2_FILE, 0, "EIA", 1);
        UploadWizard.Step4 step4 = step3.clickNext();
        AdminReviewAdjudicationsPage adjudicationReview = step4.clickFinish();

        String caseId = adjudicationReview.getSummary().getCaseId();
        Assert.assertEquals("Wrong ptid", CASE1_PTID, adjudicationReview.getSummary().getPtid());
        Assert.assertEquals("Wrong status", "Active Adjudication", adjudicationReview.getSummary().getStatus());
        Assert.assertEquals("Wrong comment", caseComment, adjudicationReview.getSummary().getComments());

        try
        {
            adjudicationReview.getCaseDocuments().getComponentElement().isDisplayed(); // Trigger staleness check
            Assert.fail("Case documents should not be visible for non-admin");
        }
        catch (NoSuchElementException expected) {}

        stopImpersonating();
        log("Validate that the case document is present for administrators only.");
        goToProjectHome();
        clickTab("Administrator Dashboard");
        waitForElement(Locator.xpath("//a[contains(@class, 'labkey-text-link')][contains(@href, 'adjid=" + caseId + "')][text()='details']"));
        clickAndWait(Locator.xpath("//a[contains(@class, 'labkey-text-link')][contains(@href, 'adjid=" + caseId + "')][text()='details']"));

        DataRegionTable table = new AdminReviewAdjudicationsPage(getDriver()).getCaseDocuments();
        Assert.assertEquals("Expected a single row in the table", 1, table.getDataRowCount());
        Assert.assertEquals("Unable to find the document : " + CASE1_FILE.getName(), table.getDataAsText(0, "DocumentName").trim(), CASE1_FILE.getName());
    }

    @Test
    public void testCaseSpaceAndDateFormat()
    {
        badCase(USER_LAB_PERSONNEL, CASE6_FILE, "format error");
/*        final String caseComment = "testCaseUpload comment " + BaseWebDriverTest.TRICKY_CHARACTERS;

        impersonate(USER_LAB_PERSONNEL);
        UploadWizard uploadWizard = UploadWizard.beginAt(this, getProjectName());
        UploadWizard.Step1 step1 = uploadWizard.startWizard();
        assertEquals("Wrong number of data rows", 0, step1.uploadDataFileWithExtraField(CASE6_FILE,"", false));
        step1 = uploadWizard.startWizard();
        assertEquals("Wrong number of data rows", 31, step1.uploadDataFileWithExtraField(CASE6_FILE,"", true));
        UploadWizard.Step2 step2 = step1.clickNext();
        assertEquals("Wrong ptid", CASE6_PTID, step2.getPtid());
        assertEquals("Wrong visits", CASE6_VISITS, step2.getVisits());
        step2.setCaseComment(caseComment);
        UploadWizard.Step3 step3 = step2.clickNext();
        UploadWizard.Step4 step4 = step3.clickNext();
        AdminReviewAdjudicationsPage adjudicationReview = step4.clickFinish();

        Assert.assertEquals("Wrong ptid", CASE6_PTID, adjudicationReview.getSummary().getPtid());
        Assert.assertEquals("Wrong status", "Active Adjudication", adjudicationReview.getSummary().getStatus());
        Assert.assertEquals("Wrong comment", caseComment, adjudicationReview.getSummary().getComments());
        //make sure date formats were parsed correctly
        assertTextPresent("01OCT2016","01AUG2016", "10OCT2016");
        assertTextNotPresent("1916");   */
    }

    @Test
    public void testAdjudicationWorkflow()
    {
        //create case
        String[] expected = {"Results", "Non-Reactive", "Reactive", "Lab Test Name", "exp data B", "exp test A", "Open Discretionary", "Total Nucleic Acid", "RNA PCR", "DNA PCR"};
        String[] unexpected = {"Band1-GP36", "Band-Foo1"};
        String caseId = _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE2_FILE, null, expected, unexpected);

        //Adjudicate 1
        AdjudicationDeterminationForm determinationForm = _adjTestSupport.beginDetermination(getProjectName(), USER_ADJUDICATOR1, caseId, 10);
        String comment1 = "Comment from first adjudicator";
        AdminReviewAdjudicationsPage reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.NO, CASE2_COLL_DATES.get(0), null, null, comment1);

        assertEquals("Wrong adjudication state after one adjudication", "Active Adjudication", reviewPage.getSummary().getStatus());

        AdminReviewAdjudicationsPage.DeterminationTable detTable1 = reviewPage.getDeterminationTable1();

        assertEquals("Incorrect adjudicator determination", "completed", detTable1.getDetermination());
        assertEquals("Incorrect adjudicator HIV-1 infection state", AdjudicationDeterminationForm.HivStatus.YES.toString(), detTable1.getHiv1InfectionState());
        assertEquals("Incorrect adjudicator HIV-1 diagnosis date", CASE2_COLL_DATES.get(0), detTable1.getHiv1InfectionDate());
        assertEquals("Incorrect adjudicator HIV-1 comment", "", detTable1.getHiv1Comment());
        assertEquals("Incorrect adjudicator HIV-2 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable1.getHiv2InfectionState());
        assertEquals("Incorrect adjudicator HIV-2 diagnosis date", "", detTable1.getHiv2InfectionDate());
        assertEquals("Incorrect adjudicator HIV-2 comment", "", detTable1.getHiv1Comment());
        assertEquals("Seeing adjudication for wrong adjudicator", USER_ADJUDICATOR1, detTable1.getAdjudicator());
        assertTextNotPresent(_userHelper.getDisplayNameForEmail(USER_ADJUDICATOR2));
        stopImpersonating();

        //Adjudicate 2 - disagree
        determinationForm = _adjTestSupport.beginDetermination(getProjectName(), USER_ADJUDICATOR2, caseId, 10);
        String comment2 = "Comment from disagreeing adjudicator";
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.INCONCLUSIVE, CASE2_COLL_DATES.get(0), null, null, comment2);

        assertEquals("Wrong adjudication state after disagreeing adjudications", "Active Adjudication", reviewPage.getSummary().getStatus());

        detTable1 = reviewPage.getDeterminationTable2();
        assertEquals("Incorrect adjudicator determination", "completed", detTable1.getDetermination());

        //Adjudicate 2 - agree but have a different date.
        AdjudicationDeterminationPage determinationPage = reviewPage.changeDetermination();
        determinationForm = determinationPage.changeDetermination();
        String commentDateDisagree = "Needed comment because disagree on dates.";
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.NO, CASE2_COLL_DATES.get(1), null, commentDateDisagree, "");

        assertEquals("Wrong adjudication state after agreeing adjudications but having a different date.", "Active Adjudication", reviewPage.getSummary().getStatus());

        detTable1 = reviewPage.getDeterminationTable2();
        assertEquals("Incorrect adjudicator determination", "completed", detTable1.getDetermination());

        assertTextPresent(commentDateDisagree);

        stopImpersonating();

        log("Validate that disagree on date sets a status of 'Resolution required'.");
        impersonate(USER_INF_MONITOR);
        goToProjectHome();
        goToAdjudicationTab(TAB_ADMIN_DASHBOARD);
        assertTextPresent("Resolution required", 1);

        stopImpersonating();

        log("Impersonate Adjudicator2 again and change determination again to agree.");
        impersonate(USER_ADJUDICATOR2);
        goToProjectHome();
        goToAdjudicationTab(TAB_CASE_DETERMINATION);
        determinationPage = new AdjudicationPage(getDriver()).goToDeterminationsAction(caseId);
        determinationPage.waitForCaseVisitRows(10);

        //Adjudicate 2 - agree
        determinationForm = determinationPage.changeDetermination();
        waitForElement(Ext4Helper.Locators.window("Adjudication Determination Form"));
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.NO, CASE2_COLL_DATES.get(0), null, null, "");

        assertEquals("Wrong adjudication state after agreeing adjudications", "Complete", reviewPage.getSummary().getStatus());
        assertNotEquals("No case completion date", "", reviewPage.getSummary().getCompletionDate());
        assertTextPresent(comment1);
        assertTextNotPresent(comment2);
        stopImpersonating();

        //Verify adjudication
        impersonate(USER_LAB_PERSONNEL);
        goToProjectHome();
        AdministratorDashboardPage dashboardPage = goToAdminDashboard();
        List<String> notifications = dashboardPage.getNotificationsWebPart().getNotifications();
        String expectedNotification = "Adjudication case #" + caseId + " has been completed, but the lab has not yet verified that they have received the data.";
        assertTrue("Didn't find expected notification: \"" + expectedNotification + "\"", notifications.contains(expectedNotification));

        dashboardPage.getAdministratorDashboardWebPart()
                .clickCaseDetails(caseId)
                .verifyReceiptOfDetermination();
        assertNotEquals("No verification date", "", reviewPage.getLabVerificationDate().trim());
        goToAdminDashboard();
        assertTextNotPresent("Adjudication Determination was completed for case " + caseId);
    }

    @Test
    public void testBackupAdjudicators()
    {
        goToSiteUsers();
        if(isElementPresent(Locator.linkWithText("INCLUDE INACTIVE USERS")))
            clickAndWait(Locator.linkWithText("INCLUDE INACTIVE USERS"));

        goToProjectHome();
        waitForElement(Locator.folderTab("Manage"));
        clickTab("Manage");

        _adjTestSupport.insertAdjudicatorUser(USER_READER2, ROLE_TO_BE_NOTIFIED);
        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR3, ROLE_ADJUDICATOR);
        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR4, ROLE_ADJUDICATOR);

        clickTab("Manage");
        AdjudicatorTeamMemberForm teamMemberWebpart = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberWebpart.assignMember(USER_ADJUDICATOR3, 1, true, true);
        teamMemberWebpart.assignMember(USER_ADJUDICATOR4, 2, true, true);
        // turn off the notifications for the first adjudicators in each team
        teamMemberWebpart.setNotificationState(1, false, false);
        teamMemberWebpart.setNotificationState(2, false, false);
        teamMemberWebpart.save(false);

        String[] expected = {"Band1-GP36", "Band2-GP140", "Band3-P31", "Band4-GP160", "Band5-P24", "Band6-GP41",
                "CTRLBand", "HIV NEGATIVE", "HIV-2 INDETERMINATE"};
        String[] unexpected = {"Band-Foo1"};
        String caseId = _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE3_FILE, null, expected, unexpected);

        _adjTestSupport.checkEmailNotifications("Adjudication Case Created");

        // Adjudicator 3 makes determination
        AdjudicationDeterminationForm determinationForm = _adjTestSupport.beginDetermination(getProjectName(), USER_ADJUDICATOR3, caseId, 8);
        String comment1 = "Comment from adjudicator 3";
        AdminReviewAdjudicationsPage reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.NO, CASE3_COLL_DATES.get(0), null, comment1, null);
        assertEquals("Wrong adjudication state after one adjudication", "Active Adjudication", reviewPage.getSummary().getStatus());
        stopImpersonating();
        _adjTestSupport.checkEmailNotifications("Adjudication Case Updated");

        // Have adjudicator 1 take a look (same team as Adjudicator 3)
        impersonate(USER_ADJUDICATOR1);
        goToProjectHome();
        goToAdjudicationTab(TAB_CASE_DETERMINATION);
        assertTextPresent("Other adjudicator in same team made determination");
        AdjudicationDeterminationPage determinationPage = new AdjudicationPage(getDriver()).goToDeterminationsAction(caseId);
        determinationPage.waitForCaseVisitRows(8);
        stopImpersonating();

        // Have adjudicator 2 make different determination
        impersonate(USER_ADJUDICATOR2);
        goToProjectHome();
        goToAdjudicationTab(TAB_CASE_DETERMINATION);
        assertTextPresent("Adjudicator in other team made determination");
        determinationPage = new AdjudicationPage(getDriver()).goToDeterminationsAction(caseId);
        determinationPage.waitForCaseVisitRows(8);
        determinationForm = determinationPage.makeDetermination();
        String commentAdjudicator2 = "No HIV (adjudicator 2)";
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.NO, HivStatus.NO, null, null,commentAdjudicator2, null);
        AdminReviewAdjudicationsPage.DeterminationTable detTable2 = reviewPage.getDeterminationTable2();

        assertEquals("Incorrect adjudicator determination", "completed", detTable2.getDetermination());
        assertEquals("Incorrect adjudicator HIV-1 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable2.getHiv1InfectionState());
        assertEquals("Incorrect adjudicator HIV-1 comment", commentAdjudicator2, detTable2.getHiv1Comment());
        assertEquals("Incorrect adjudicator HIV-2 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable2.getHiv2InfectionState());
        assertEquals("Seeing adjudication for wrong adjudicator", USER_ADJUDICATOR2, detTable2.getAdjudicator());
        assertTextNotPresent(_userHelper.getDisplayNameForEmail(USER_ADJUDICATOR1));
        assertTextNotPresent(_userHelper.getDisplayNameForEmail(USER_ADJUDICATOR3));
        stopImpersonating();
        _adjTestSupport.checkEmailNotifications("Adjudication Case Updated");

        // Have Infection Monitor check
        impersonate(USER_INF_MONITOR);
        goToProjectHome();
        clickTab(TAB_ADMIN_DASHBOARD);
        AdministratorDashboard administratorDashboard = new AdministratorDashboard(getDriver());
        waitForText("Resolution required");
        reviewPage = administratorDashboard.clickCaseDetails(caseId);
        Assert.assertEquals("Wrong status", "Active Adjudication", reviewPage.getSummary().getStatus());
        AdminReviewAdjudicationsPage.DeterminationTable detTable1 = reviewPage.getDeterminationTable1();
        detTable2 = reviewPage.getDeterminationTable2();

        assertEquals("Incorrect adjudicator determination", "completed", detTable1.getDetermination());
        assertEquals("Incorrect adjudicator HIV-1 infection state", AdjudicationDeterminationForm.HivStatus.YES.toString(), detTable1.getHiv1InfectionState());
        assertEquals("Incorrect adjudicator HIV-2 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable1.getHiv2InfectionState());
        assertEquals("Determination team 1 adjudicator incorrect", USER_ADJUDICATOR3, detTable1.getAdjudicator());

        assertEquals("Incorrect adjudicator determination", "completed", detTable2.getDetermination());
        assertEquals("Incorrect adjudicator HIV-1 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable2.getHiv1InfectionState());
        assertEquals("Incorrect adjudicator HIV-2 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable2.getHiv2InfectionState());
        assertEquals("Determination team 2 adjudicator incorrect", USER_ADJUDICATOR2, detTable2.getAdjudicator());
        stopImpersonating();

        // Have adjudicator 4 change determination
        determinationForm = _adjTestSupport.beginDetermination(getProjectName(), USER_ADJUDICATOR4, caseId, 8, true);
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.NO, CASE3_COLL_DATES.get(0), null, "Adjudicator 4 comment", null);
        assertEquals("Wrong adjudication state after one adjudication", "Complete", reviewPage.getSummary().getStatus());
        detTable1 = reviewPage.getDeterminationTable1();
        detTable2 = reviewPage.getDeterminationTable2();
        assertEquals("Incorrect adjudicator determination", "completed", detTable1.getDetermination());
        assertEquals("Incorrect adjudicator HIV-1 infection state", AdjudicationDeterminationForm.HivStatus.YES.toString(), detTable1.getHiv1InfectionState());
        assertEquals("Incorrect adjudicator HIV-2 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable1.getHiv2InfectionState());
        assertEquals("Determination team 1 adjudicator incorrect", USER_ADJUDICATOR3, detTable1.getAdjudicator());

        assertEquals("Incorrect adjudicator determination", "completed", detTable2.getDetermination());
        assertEquals("Incorrect adjudicator HIV-1 infection state", AdjudicationDeterminationForm.HivStatus.YES.toString(), detTable2.getHiv1InfectionState());
        assertEquals("Incorrect adjudicator HIV-2 infection state", AdjudicationDeterminationForm.HivStatus.NO.toString(), detTable2.getHiv2InfectionState());
        assertEquals("Determination team 2 adjudicator incorrect", USER_ADJUDICATOR4, detTable2.getAdjudicator());
        stopImpersonating();

        _adjTestSupport.checkEmailNotifications("Adjudication Case Completed");

        // Check another case with new fields
        String[] expected4 = {"Band1-GP36", "Band2-GP140", "Band3-P31", "Band4-GP160", "Band5-P24", "Band Foo 1",
                "CTRLBand", "HIV NEGATIVE", "HIV-2 INDETERMINATE"};
        String[] unexpected4 = {"Band6-GP41"};
        _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE4_FILE, null, expected4, unexpected4);

        // check email notifications for each of the event types
        goToProjectHome();
        _adjTestSupport.checkCaseEmailNotifications("Adjudication Case Created", null, 12);
        _adjTestSupport.checkCaseEmailNotifications("Adjudication Case Determination Updated", null, 8);
        _adjTestSupport.checkCaseEmailNotifications("Adjudication Case Resolution Required", null, 1);
        _adjTestSupport.checkCaseEmailNotifications("Adjudication Case Completed", null, 6);
        // check email notification count for each of the adjudicator users
        _adjTestSupport.checkCaseEmailNotifications(USER_ADJUDICATOR3, 3);
        _adjTestSupport.checkCaseEmailNotifications(USER_ADJUDICATOR4, 3);
        _adjTestSupport.checkCaseEmailNotifications(USER_ADJUDICATOR3 + ", " + USER_ADJUDICATOR4, 1);
        // verify that the adjudicators that had notifications turned off didn't receive notifications
        _adjTestSupport.checkCaseEmailNotifications(USER_ADJUDICATOR1, 0);
        _adjTestSupport.checkCaseEmailNotifications(USER_ADJUDICATOR2, 0);
    }

    private void goToAdjudicationTab(String tab)
    {
        clickTab(tab);
        waitForElement(Locator.tagWithClass("div", "gridOne").containing("Active"));
    }

    @Test
    public void testBadInputFiles()
    {
        goToProjectHome();
        badCase(USER_LAB_PERSONNEL, CASE2_BADFILE, "Unexpected file name:");
        badCase(USER_LAB_PERSONNEL, CASE1_BADFILE, "Multiple PTIDs found in uploaded data file.");
        badCase(USER_LAB_PERSONNEL, CASE3_BADFILE, "PTID does not match file name.");
    }

    @Test
    public void testNotifications()
    {
        // create a new case and append the same data to that case so we get notifications for those two event types
        _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE7_FILE);
        String caseId = _adjTestSupport.appendAssayData(getProjectName(), USER_LAB_PERSONNEL, CASE7_CS_FILE);

        String newCaseNotif = "A new adjudication case, #" + caseId + ", has been created.";
        String assayDataNotif = "Assay data for case #" + caseId + " has been updated.";
        String resolutionNotif = "Adjudication case #" + caseId + " requires resolution.";
        String completedNotif = "Adjudication case #" + caseId + " has been completed.";
        String verificationNotif = "Adjudication case #" + caseId + " has been completed, but the lab has not yet verified that they have received the data.";

        String newCaseSubj = "Adjudication Case Created";
        String newCaseBody = "A new adjudication case, #" + caseId + ", has been created for /AdjudicationTest Project.";
        String caseDataUpdatedSubj = "Adjudication Case Assay Data Updated";
        String caseDataUpdatedBody = "Assay data for case #" + caseId + " has been updated for /AdjudicationTest Project.";
        String caseAdjudicationDeterminationUpdatedSubj = "Adjudication Case Determination Updated";
        String caseAdjudicationUpdatedDeterminationBody = "Adjudication case #" + caseId + " has an updated determination for /AdjudicationTest Project.";
        String caseRequiresResolutionSubj = "Adjudication Case Resolution Required";
        String caseRequiresResolutionBody = "Adjudication case #" + caseId + " requires resolution for /AdjudicationTest Project.";
        String caseCompletedSubj = "Adjudication Case Completed";
        String caseCompletedBody = "Adjudication case #" + caseId + " has been completed for /AdjudicationTest Project.";

        // set determination by first adjudicator so we get the updated determination event notifications
        // and check for UI notifications on adjudicator dashboard along the way
        impersonate(USER_ADJUDICATOR1);
        goToProjectHome();
        clickTab(TAB_CASE_DETERMINATION);
        verifyDashboardNotifications(caseId, Arrays.asList(newCaseNotif, assayDataNotif), Arrays.asList(resolutionNotif, completedNotif));
        // test dismiss link from dashboard page
        Notifications notifications = new Notifications(this);
        int notifIndex = notifications.getNotifications().indexOf(newCaseNotif);
        clickAndWait(Locator.linkContainingText("dismiss").index(notifIndex));
        verifyDashboardNotifications(caseId, Arrays.asList(assayDataNotif), Arrays.asList(newCaseNotif, resolutionNotif, completedNotif));
        // make determination (note: going to that page will dismiss the remaining notification)
        AdjudicationDeterminationForm deterForm = _adjTestSupport.goToCaseDetermination(caseId, 1, false);
        _adjTestSupport.makeDetermination(deterForm, HivStatus.NO, HivStatus.NO);
        goToAdjudicationTab(TAB_CASE_DETERMINATION);
        assertElementNotPresent(Notifications.getCaseNotificationsLocator(caseId));
        stopImpersonating();

        // set mismatched determination by second adjudicator so we get the resolution required event notification
        // and check for UI notifications on adjudicator dashboard along the way
        impersonate(USER_ADJUDICATOR2);
        goToProjectHome();
        clickTab(TAB_CASE_DETERMINATION);
        waitForElement(Locator.tagWithText("td", "Adjudicator in other team made determination"));
        verifyDashboardNotifications(caseId, Arrays.asList(newCaseNotif, assayDataNotif), Arrays.asList(resolutionNotif, completedNotif));
        deterForm = _adjTestSupport.goToCaseDetermination(caseId, 1, false);
        _adjTestSupport.makeDetermination(deterForm, HivStatus.NO, HivStatus.INCONCLUSIVE, null, null, null, "testing resolution required");
        clickTab(TAB_CASE_DETERMINATION);
        verifyDashboardNotifications(caseId, Arrays.asList(resolutionNotif), Arrays.asList(newCaseNotif, assayDataNotif, completedNotif));
        // change second adjudicator determination to match so we get the completed case event notifications
        deterForm = _adjTestSupport.goToCaseDetermination(caseId, 1, true);
        _adjTestSupport.makeDetermination(deterForm, HivStatus.NO, HivStatus.NO);
        goToAdjudicationTab(TAB_CASE_DETERMINATION);
        assertElementNotPresent(Notifications.getCaseNotificationsLocator(caseId));
        stopImpersonating();

        // check UI dashboard notifications for infection monitor
        impersonate(USER_INF_MONITOR);
        goToProjectHome();
        clickTab(TAB_ADMIN_DASHBOARD);

        // test notification dismiss from viewing the case details page
        AdministratorDashboard administratorDashboard = new AdministratorDashboard(getDriver());
        administratorDashboard.clickCaseDetails(caseId);
        goToAdjudicationTab(TAB_ADMIN_DASHBOARD);
        assertElementNotPresent(Notifications.getCaseNotificationsLocator(caseId));
        stopImpersonating();

        // check UI dashboard notifications for lab personnel
        impersonate(USER_LAB_PERSONNEL);
        goToProjectHome();
        clickTab(TAB_ADMIN_DASHBOARD);
        verifyDashboardNotifications(caseId, Arrays.asList(verificationNotif), Arrays.asList(newCaseNotif, assayDataNotif, completedNotif, resolutionNotif));
        // test notification dismiss by verifying determination receipt
        administratorDashboard = new AdministratorDashboard(getDriver());
        AdminReviewAdjudicationsPage reviewPage = administratorDashboard.clickCaseDetails(caseId);
        reviewPage.verifyReceiptOfDetermination();
        goToAdjudicationTab(TAB_ADMIN_DASHBOARD);
        assertElementNotPresent(Notifications.getCaseNotificationsLocator(caseId));
        stopImpersonating();

        // check UI dashboard notifications for data reviewer (should see none)
        impersonate(USER_DATA_REVIEWER);
        goToProjectHome();
        goToAdjudicationTab(TAB_ADMIN_DASHBOARD);
        assertElementNotPresent(Notifications.getCaseNotificationsLocator(caseId));
        stopImpersonating();

        // check UI dashboard notifications for Folder Admin
        goToProjectHome();
        clickTab(TAB_ADMIN_DASHBOARD);
        verifyDashboardNotifications(caseId, Arrays.asList(newCaseNotif, assayDataNotif, completedNotif), Arrays.asList(verificationNotif, resolutionNotif));
        // test notification dismiss from viewing the case details page
        administratorDashboard = new AdministratorDashboard(getDriver());
        administratorDashboard.clickCaseDetails(caseId);
        goToAdjudicationTab(TAB_ADMIN_DASHBOARD);
        assertElementNotPresent(Notifications.getCaseNotificationsLocator(caseId));

        // check email notifications for each of the users
        goToModule("Dumbster");

        List<EmailRecordTable.EmailMessage> messages = _adjTestSupport.getEmailsToUser(USER_ADJUDICATOR1);
        assertEquals("Did not find expected message count for user " + USER_ADJUDICATOR1, 3, messages.size());
        assertEquals("Did not find case completed message for user " + USER_ADJUDICATOR1, 1, _adjTestSupport.filterEmailBySubject(messages, caseCompletedSubj).size());
        assertEquals("Did not find case assay data updated message for user " + USER_ADJUDICATOR1, 1, _adjTestSupport.filterEmailBySubject(messages, caseDataUpdatedSubj).size());
        assertEquals("Did not find case completed message for user " + USER_ADJUDICATOR1, 1, _adjTestSupport.filterEmailBySubject(messages, newCaseSubj).size());
        messages = _adjTestSupport.getEmailsToUser(USER_ADJUDICATOR1 + ", " + USER_ADJUDICATOR2);
        assertEquals("Did not find expected message count for users " + USER_ADJUDICATOR1 + " and " + USER_ADJUDICATOR2, 1, _adjTestSupport.filterEmailBySubject(messages, caseRequiresResolutionSubj).size());
        messages = _adjTestSupport.getEmailsToUser(USER_LAB_PERSONNEL);
        assertEquals("Did not find expected message count for user " + USER_LAB_PERSONNEL, 5, messages.size());
        assertEquals("Did not find case completed message for user " + USER_LAB_PERSONNEL, 1, _adjTestSupport.filterEmailBySubject(messages, caseCompletedSubj).size());
        assertEquals("Did not find case assay data updated message for user " + USER_LAB_PERSONNEL, 1, _adjTestSupport.filterEmailBySubject(messages, caseDataUpdatedSubj).size());
        assertEquals("Did not find case determination updated message for user " + USER_LAB_PERSONNEL, 2, _adjTestSupport.filterEmailBySubject(messages, caseAdjudicationDeterminationUpdatedSubj).size());
        assertEquals("Did not find case created message for user " + USER_LAB_PERSONNEL, 1, _adjTestSupport.filterEmailBySubject(messages, newCaseSubj).size());
        messages = _adjTestSupport.getEmailsToUser(USER_DATA_REVIEWER);
        assertEquals("Did not find expected message count for user " + USER_DATA_REVIEWER, 4, messages.size());
        assertEquals("Did not find case determination updated message for user " + USER_DATA_REVIEWER, 2, _adjTestSupport.filterEmailBySubject(messages, caseAdjudicationDeterminationUpdatedSubj).size());
        assertEquals("Did not find case created message for user " + USER_DATA_REVIEWER, 1, _adjTestSupport.filterEmailBySubject(messages, newCaseSubj).size());
        assertEquals("Did not find case assay data updated message for user " + USER_DATA_REVIEWER, 1, _adjTestSupport.filterEmailBySubject(messages, caseDataUpdatedSubj).size());

        //Check content of messages and link to adjudication review/determination
        String adminReviewLink = _adjTestSupport.buildAdjudicationReviewLink(true, caseId);
        String nonAdminReviewLink = _adjTestSupport.buildAdjudicationReviewLink(false, caseId);
        String determinationLink = _adjTestSupport.buildAdjudicationDeterminationLink(caseId);
        log(String.format("Checking for notification links:\nadminReview: %s\nnonAdminReview: %s\ndetermination:%s", adminReviewLink, nonAdminReviewLink, determinationLink));
        assertTrue ("Case completed message did not contain link to review ",_adjTestSupport.getEmailBySubject(caseCompletedSubj).getBody().contains(nonAdminReviewLink));
        assertTrue ("Case requires resolution message did not contain link to review ",_adjTestSupport.getEmailBySubject(caseRequiresResolutionSubj).getBody().contains(determinationLink));
        assertTrue ("Case adjudication updated message did not contain link to review ",_adjTestSupport.getEmailBySubject(caseAdjudicationDeterminationUpdatedSubj).getBody().contains(adminReviewLink));
        assertTrue ("Case assay data updated message did not contain link to review ",_adjTestSupport.getEmailBySubject(caseDataUpdatedSubj).getBody().contains(adminReviewLink));
        assertTrue ("Case created message did not contain link to review ",_adjTestSupport.getEmailBySubject(newCaseSubj).getBody().contains(adminReviewLink));

    }

    @Test
    public void testUpdateCase()
    {
        int emailsBefore, emailsAfter;
        String caseId, comment1, comment2;
        AdjudicationDeterminationForm determinationForm;
        AdminReviewAdjudicationsPage reviewPage;
        List<String> step2ExpectedText = Arrays.asList("A completed adjudication case already exists with this file.",
                "Merge will add the assay results from the uploaded TXT file to the completed case. It will not remove any previously uploaded assay results, case details, or determinations.",
                "Exit wizard to exit the upload wizard. Please contact the Adjudication Coordinator or a site administrator if the case is not supposed to have already been completed.");

        log("First get a base count of the number of emails to " + USER_INF_MONITOR);
        goToModule("Dumbster");
        emailsBefore = _adjTestSupport.getEmailsToUser(USER_INF_MONITOR).size();
        goToProjectHome();

        log("Create a new case");
        caseId = _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, UPDATE_CASE_ORIGINAL);

        log("Have " + USER_ADJUDICATOR1 + " mark the case.");
        determinationForm = _adjTestSupport.beginDetermination(getProjectName(), USER_ADJUDICATOR1, caseId, 8);
        comment1 = "First comment from first adjudicator";
        comment2 = "Second comment from first adjudicator";
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.YES, UPDATE_CASE_COLL_DATES.get(UPDATE_CASE_COLL_DATES.size() - 1), UPDATE_CASE_COLL_DATES.get(UPDATE_CASE_COLL_DATES.size() - 1), comment1, comment2);
        goToProjectHome();
        stopImpersonating();

        log("Have " + USER_ADJUDICATOR2 + " mark the case.");
        determinationForm = _adjTestSupport.beginDetermination(getProjectName(), USER_ADJUDICATOR2, caseId, 8);
        comment1 = "First comment from second adjudicator";
        comment2 = "Second comment from second adjudicator";
        reviewPage = _adjTestSupport.makeDetermination(determinationForm, HivStatus.YES, HivStatus.YES, UPDATE_CASE_COLL_DATES.get(UPDATE_CASE_COLL_DATES.size() - 1), UPDATE_CASE_COLL_DATES.get(UPDATE_CASE_COLL_DATES.size() - 1), comment1, comment2);
        goToProjectHome();
        stopImpersonating();

        log("The case should be resolved. Check that there is only one email to " + USER_INF_MONITOR);
        goToModule("Dumbster");
        emailsAfter = _adjTestSupport.getEmailsToUser(USER_INF_MONITOR).size();
        Assert.assertEquals("Number of emails to " + USER_INF_MONITOR + " not as expected.", emailsBefore + 1, emailsAfter);
        goToProjectHome();

        log("Now have " + USER_LAB_PERSONNEL + " 'append' an updated file.");

        log("First validate that the text is as expected, and exit works as expected.");
        impersonate(USER_LAB_PERSONNEL);
        UploadWizard uploadWizard = UploadWizard.beginAt(this, getProjectName());
        UploadWizard.Step1 step1 = uploadWizard.startWizard();
        step1.uploadDataFile(UPDATE_CASE_UPDATE);
        UploadWizard.Step2 step2 = step1.clickNext();
        String step2Text = step2.getStatusText();
        Assert.assertTrue("Step 2 did not contain the expected text '" + step2ExpectedText.get(0) + "'.", step2Text.contains(step2ExpectedText.get(0)));
        Assert.assertTrue("Step 2 did not contain the expected text '" + step2ExpectedText.get(1) + "'.", step2Text.contains(step2ExpectedText.get(1)));
        Assert.assertTrue("Step 2 did not contain the expected text '" + step2ExpectedText.get(2) + "'.", step2Text.contains(step2ExpectedText.get(2)));
        step2.clickExitWizard();
        log("Validate we are still on the 'Upload Wizard'");
        assertTextPresent("Upload Wizard");
        goToProjectHome();
        stopImpersonating();

        log("Now actually append the updated data.");
        _adjTestSupport.appendAssayData(getProjectName(), USER_LAB_PERSONNEL, UPDATE_CASE_UPDATE, true);

        log("Validate that the updated content is present.");
        goToProjectHome();
        AdminReviewAdjudicationsPage reviewAdjudicationsPage = goToAdminDashboard().getAdministratorDashboardWebPart()
                .clickCaseDetails(caseId);
        // waitForElement(Locators.pageSignal("determinationTablesLoaded")); // This signal fires too early
        waitForText("Comment from visit 1. Record updated");

        // ensure the case document web part contains both files uploaded
        DataRegionTable table = reviewAdjudicationsPage.getCaseDocuments();
        Assert.assertEquals("Expected 2 rows in the table", 2, table.getDataRowCount());
        Assert.assertEquals("Unable to find the document: " + UPDATE_CASE_UPDATE.getName(), UPDATE_CASE_UPDATE.getName(), table.getDataAsText(0, "DocumentName").trim());
        Assert.assertEquals("Unable to find the document: " + UPDATE_CASE_UPDATE.getName(), UPDATE_CASE_UPDATE.getName(), table.getDataAsText(1, "DocumentName").trim());

        log("Now validate that the Infection Monitor page is present.");
        goToProjectHome();
        impersonate(USER_INF_MONITOR);
        sleep(500);
        clickTab("Infection Monitor");

        InfectionMonitorPage infPage = new InfectionMonitorPage(getDriver());
        int rowIndex = infPage.getDataRegion().getRowIndex("CaseId", caseId);
        Assert.assertEquals("Did not find the expected participant id in the row for this case.", "100000001", infPage.getDataRegion().getDataAsText(rowIndex, "ParticipantId"));
        stopImpersonating();

        // go to schema browser to validate the case document table
        goToProjectHome();
        goToSchemaBrowser();
        selectQuery("adjudication", "CaseDocuments");
        waitForText("view data");
        clickAndWait(Locator.linkContainingText("view data"));
        DataRegionTable drt = new DataRegionTable("query", this);

        for (int i=0; i < drt.getDataRowCount(); i++)
        {
            if (drt.getDataAsText(i, "CaseId").equalsIgnoreCase(caseId))
                Assert.assertEquals(drt.getDataAsText(i, "DocumentName").trim(), UPDATE_CASE_UPDATE.getName());
        }

        // verify only administrators can view the case documents table
        impersonate(USER_INF_MONITOR);
        goBack();
        waitForText("Only administrators can view the Case Documents Table");
        goToHome();
        stopImpersonating();
    }

    @Test
    public void testAdminResultDelete()
    {
        _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE5_FILE);
        goToProjectHome();
        goToSchemaBrowser();
        selectQuery("adjudication", "AssayResults");
        click(Locator.linkWithText("View Data"));
        DataRegionTable drt = new DataRegionTable("query", getWrappedDriver());
        drt.checkAll();
        drt.clickHeaderButtonByText("Delete");
        assertAlert("Are you sure you want to delete the selected rows?");
    }

    @Test
    public void testManualReminderEmailNotification()
    {
        log("Create a new case");
        String caseId = _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE11_FILE);
        goToProjectHome();
        clickTab("Manage");
        waitForText("Adjudication Email Reminders");
        click(Locator.linkWithText("Cases"));
        log("Click the email reminder link");
        DataRegionTable table = new DataRegionTable("query",getDriver());
        table.setSort("Created", SortDirection.DESC);
        clickButton("Send Email Reminder");
        log ("Dumbster for verifiying whether the email was sent");
        goToModule("Dumbster");
        EmailRecordTable.EmailMessage message = _adjTestSupport.getEmailBySubject("Reminder - Adjudication Case Needs Determination");
        String caseId_email = message.getBody().substring(message.getBody().indexOf('#')+1,message.getBody().indexOf(" ",message.getBody().indexOf('#')));
        log("Comparing the caseId to be same.");
        assertEquals("The caseId from the manage tab does not match with message body",caseId,caseId_email);

    }

    @Test
    public void testManualReminderForReaders()
    {
        log("Create a new case");
        _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE12_FILE);
        goToProjectHome();
        clickTab("Manage");
        waitForText("Adjudication Email Reminders");
        clickAndWait(Locator.linkWithText("Cases"));
        log("Imapersonate as Reader - checking if Send Email Reminder button is accessable");
        impersonateRoles("Reader");
        assertElementNotPresent("Readers should not have the send email reminder option",Locator.buttonContainingText("Send Email Reminder"));
        stopImpersonating();
    }

    @Test
    public void testAutomaticReminder()
    {
        String caseReminderSub = "Reminder - Adjudication Case Needs Determination";
        goToProjectHome();
        clickTab("Manage");
        waitForText("Adjudication Email Reminders");
        clickAndWait(Locator.linkWithText("Cases"));
        DataRegionTable table = new DataRegionTable("query",getDriver());
        table.setFilter("StatusId", "Contains","Active Adjudication");
        int countFromSchemaBrowswer = table.getDataRowCount();

        goToModuleProperties();
        sleep(500);

        log("Checking the checkbox for enabling the automatic remeinder");
        Checkbox.Ext4Checkbox().withLabel("AdjudicationTest Project:").find(getDriver()).check();
        clickButton("Save Changes",0);
        Window msgWindow = new Window("Success", this.getDriver());
        assertTrue(msgWindow.getBody().contains("Properties saved"));
        msgWindow.clickButton("OK", 0);
        goToAdminConsole().clickSystemMaintenance();
        click(Locator.linkWithText("Send emails to adjudicators who have not made a determination or have cases that need resolution."));
        sleep(500);
        goToProjectHome();
        goToModule("Dumbster");
        List<EmailRecordTable.EmailMessage> messages = _adjTestSupport.getEmailsToUser(USER_ADJUDICATOR3 + ", " + USER_ADJUDICATOR4 );
        List<EmailRecordTable.EmailMessage> reminderEmails = _adjTestSupport.filterEmailBySubject(messages,caseReminderSub);
        log("Comparing the count to be same.");
        assertEquals("The count of the email sent automatically dosnt match with dumbster",countFromSchemaBrowswer,reminderEmails.size());

    }

    @Test
    public void verifyAddingNewAssayType()
    {
        String newAssay = "newasy";
        log("Create a new case");
        String caseId = _adjTestSupport.createCase(getProjectName(), USER_LAB_PERSONNEL, CASE14_FILE);
        goToProjectHome();

        log("Checking for the new assaytype");
        clickTab("Administrator Dashboard");
        waitAndClickAndWait(Locator.xpath("//a[contains(@class, 'labkey-text-link')][contains(@href, 'adjid=" + caseId + "')][text()='details']"));
        waitForElement(Locator.tagWithAttribute("table","class","result-table"));
        assertTextNotPresent(newAssay);

        log("Adding new assay type");
        clickTab("Manage");
        DataRegionTable table = new DataRegionTable("adjassaytype",getDriver());
        table.clickInsertNewRow();
        setFormElement(Locator.name("quf_Name"),newAssay);
        setFormElement(Locator.name("quf_Label"),newAssay);
        clickButton("Submit");

        log("Checking for the new assaytype");
        clickTab("Administrator Dashboard");
        waitAndClickAndWait(Locator.xpath("//a[contains(@class, 'labkey-text-link')][contains(@href, 'adjid=" + caseId + "')][text()='details']"));
        waitForElement(Locator.tagWithAttribute("table","class","result-table"));
        assertTextPresent(newAssay);

    }

    @Test
    public void verifyRemovingAssayType()
    {
        String assayType = "testing";

        log("Going to project home");
        goToProjectHome();
        clickTab("Manage");
        DataRegionTable table = new DataRegionTable("adjassaytype",getDriver());
        table.clickInsertNewRow();
        log("Inserting new assay type");
        setFormElement(Locator.name("quf_Name"),assayType);
        setFormElement(Locator.name("quf_Label"),assayType);
        clickButton("Submit",WAIT_FOR_PAGE);

        log("Verifying if the assay is added");
        table.setFilter("Name","Equals",assayType);
        int count = table.getDataRowCount();
        assertEquals("Assay type not added",1,count);

        log("Deleting the added assya type");
        table.checkCheckbox(table.getRowIndex("Name",assayType));
        table.clickHeaderButton("Delete");
        assertAlert("Are you sure you want to delete the selected row?");

        log ("Verifying the deletion");
        table.setFilter("Name","Equals",assayType);
        count = table.getDataRowCount();
        assertEquals("Assay type not removed",0,count);

    }

    private void verifyDashboardNotifications(String caseId, @NotNull List<String> expected, @Nullable List<String> notExpected)
    {
        Notifications notifications = new Notifications(this);
        waitForElements(Notifications.getCaseNotificationsLocator(caseId), expected.size());

        List<String> actualNotifications = notifications.getNotifications();
        for (String expectedStr : expected)
        {
            assertTrue("Expected notification not present: " + expectedStr, actualNotifications.contains(expectedStr));
        }

        if (notExpected != null)
        {
            for (String notExpectedNotif : notExpected)
                assertTrue("Unexpected notification present: " + notExpectedNotif, !actualNotifications.contains(notExpectedNotif));
        }
    }

    @Override
    protected BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    protected String getProjectName()
    {
        return "AdjudicationTest Project";
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("adjudication");
    }

    private void badCase(String labPerson, File casePath, String expectedError)
    {
        impersonate(labPerson);
        UploadWizard uploadWizard = UploadWizard.beginAt(this, getProjectName());
        UploadWizard.Step1 step1 = uploadWizard.startWizard();
        waitForText("Click here to browse");
        step1.uploadDataFileExpectingError(casePath, expectedError);
        stopImpersonating();
    }

}