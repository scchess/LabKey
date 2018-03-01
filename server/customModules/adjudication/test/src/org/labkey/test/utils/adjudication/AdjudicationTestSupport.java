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
package org.labkey.test.utils.adjudication;

import org.jetbrains.annotations.Nullable;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.PropertiesEditor;
import org.labkey.test.components.adjudication.AdjudicationDeterminationForm;
import org.labkey.test.components.adjudication.AdjudicatorTeamMemberForm;
import org.labkey.test.components.adjudication.AdminSettingsForm;
import org.labkey.test.components.dumbster.EmailRecordTable;
import org.labkey.test.pages.adjudication.AdjudicationDeterminationPage;
import org.labkey.test.pages.adjudication.AdjudicationPage;
import org.labkey.test.pages.adjudication.AdminReviewAdjudicationsPage;
import org.labkey.test.pages.adjudication.UploadWizard;
import org.labkey.test.params.FieldDefinition;
import org.labkey.test.util.ApiPermissionsHelper;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.LoggedParam;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PortalHelper;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertTrue;

public class AdjudicationTestSupport extends WebDriverWrapper
{
    private final BaseWebDriverTest _test;

    public AdjudicationTestSupport(BaseWebDriverTest test)
    {
        _test = test;
    }

    @Override
    public WebDriver getWrappedDriver()
    {
        return _test.getDriver();
    }

    public void createAdjudicationProject(String projectName, @Nullable String[] usersReaders, @Nullable String[] adjudicationUsers,
          @Nullable String numAdjTeams, @Nullable String filePrefix, @Nullable String hivType, @Nullable String[] assayResultsField)
    {
        String[] temp;
        String user, role;
        String fieldName, fieldLabel;
        ApiPermissionsHelper apiPermissionsHelper = new ApiPermissionsHelper(this);

        log("Going to create an adjudication project that looks only at '" + hivType + "'");

        _test._containerHelper.createProject(projectName, "Adjudication");

        // Folder permissions setup
        if (usersReaders != null && usersReaders.length > 0)
        {
            for (String usersReader : usersReaders)
                apiPermissionsHelper.setUserPermissions(usersReader, "Reader");
        }

        // Admin Settings
        waitForElement(Locator.folderTab("Manage"));
        _test.clickTab("Manage");
        AdminSettingsForm adminSettingsForm = new AdminSettingsForm(this.getDriver());
        if(filePrefix != null)
            adminSettingsForm.setFilenamePrefixText(filePrefix);
        if(numAdjTeams != null)
            adminSettingsForm.setNumberOfTeams(numAdjTeams);
        adminSettingsForm.setHivTypesRequired(hivType != null ? hivType : "Both HIV-1 and HIV-2");
        adminSettingsForm.save();

        // Adjudication Users webpart configuration and role permissions setup
        if (adjudicationUsers != null && adjudicationUsers.length > 0)
        {
            for (String adjudicationUser : adjudicationUsers)
            {
                temp = adjudicationUser.split(";");
                user = temp[0];
                role = temp[1];
                insertAdjudicatorUser(user, role);
            }

            // Adjudicator team members
            AdjudicatorTeamMemberForm teamMemberWebpart = new AdjudicatorTeamMemberForm(this.getDriver());
            boolean toSaveTeamMembers = false;
            for (String adjudicationUser : adjudicationUsers)
            {
                temp = adjudicationUser.split(";");
                if (temp.length == 3)
                {
                    teamMemberWebpart.assignMember(temp[0], Integer.parseInt(temp[2]), false, true);
                    toSaveTeamMembers = true;
                }
            }
            if (toSaveTeamMembers)
                teamMemberWebpart.save(false);
        }

        // Add Assay Results field
        if(assayResultsField != null)
        {
            for (String field : assayResultsField)
            {
                temp = field.split(";");
                fieldName = temp[0];
                fieldLabel = temp[1];
                clickAndWait(Locator.linkContainingText("Configure Assay Results"));
                PropertiesEditor propertiesEditor = PropertiesEditor.PropertiesEditor(getDriver()).withTitle("Field Properties").waitFor();
                propertiesEditor.addField(new FieldDefinition(fieldName).setLabel(fieldLabel).setType(FieldDefinition.ColumnType.String));
            }
            clickButton("Save");
            waitForText("Manage Adjudication");
        }
    }

    public String createCase(String projectName, String labPerson, File casePath)
    {
        return createCase(projectName, labPerson, casePath, null, new String[]{}, new String[]{});
    }

    @LogMethod
    public String createCase(String projectName, String labPerson, @LoggedParam File casePath, @Nullable String caseComment, String[] expectedText, String[] unexpectedText)
    {
        _test.impersonate(labPerson);
        UploadWizard uploadWizard = UploadWizard.beginAt(_test, projectName);
        UploadWizard.Step1 step1 = uploadWizard.startWizard();
        step1.uploadDataFile(casePath);
        UploadWizard.Step2 step2 = step1.clickNext();
        if(caseComment != null)
            step2.setCaseComment(caseComment);
        UploadWizard.Step3 step3 = step2.clickNext();
        sleep(1000); // the next button can move if the step 3 content is longer than 6 or 7 rows
        UploadWizard.Step4 step4 = step3.clickNext();
        String caseId = step4.clickFinish().getSummary().getCaseId();

        if (expectedText.length > 0)
            assertTextPresent(expectedText);

        if (unexpectedText.length > 0)
            assertTextNotPresent(unexpectedText);

        _test.stopImpersonating();

        log("Case created: " + caseId);
        return caseId;
    }

    public String appendAssayData(String projectName, String labPerson, File casePath)
    {
        return appendAssayData(projectName, labPerson, casePath, false);
    }

    public String appendAssayData(String projectName, String labPerson, File casePath, boolean afterCaseCompletion)
    {
        _test.impersonate(labPerson);
        UploadWizard uploadWizard = UploadWizard.beginAt(_test, projectName);
        UploadWizard.Step1 step1 = uploadWizard.startWizard();
        step1.uploadDataFile(casePath);
        UploadWizard.Step2 step2 = step1.clickNext();
        step2.clickMerge(afterCaseCompletion);
        UploadWizard.Step3 step3 = step2.clickNext();
        sleep(1000); // the next button can move if the step 3 content is longer than 6 or 7 rows
        UploadWizard.Step4 step4 = step3.clickNext();
        String caseId = step4.clickFinish().getSummary().getCaseId();
        _test.stopImpersonating();

        log("Case assay data appended: " + caseId);
        return caseId;
    }

    public void insertAdjudicatorUser(String userEmail, String role)
    {
        if (!isElementPresent(Locator.tagWithText("span", "Manage Adjudication")))
            _test.clickTab("Manage");

        new DataRegionTable("adjuser", this).clickInsertNewRow();
        WebElement select = Locator.name("quf_UserId").waitForElement(shortWait());
        selectOptionByText(select, userEmail);
        selectOptionByText(Locator.name("quf_RoleId"), role);
        clickButton("Submit");
    }

    public void checkEmailNotifications(String subject, String... users)
    {
        int expectedCount = users.length;

        log("Check notification emails");
        _test.goToHome();
        goToModule("Dumbster");
        assertTrue("Expected '" + subject + "' at least " + expectedCount + " times", countText(subject) >= expectedCount);
        for (String user: users)
        {
            assertTextPresent(user);
        }
    }

    public void checkCaseEmailNotifications(String subject, @Nullable String body, int count)
    {
        if (!isElementPresent(PortalHelper.Locators.webPartTitle("Mail Record")))
            goToModule("Dumbster");

        waitForElements(Locator.tagWithText("a", subject), count);

        if (body != null)
            assertElementPresent(Locator.tagContainingText("div", body), count);
    }

    public void checkCaseEmailNotifications(String userEmail, int count)
    {
        if (!isElementPresent(PortalHelper.Locators.webPartTitle("Mail Record")))
            goToModule("Dumbster");

        if (count > 0)
            waitForElements(Locator.tagWithText("td", userEmail), count);
        else
            assertElementNotPresent(Locator.tagWithText("td", userEmail));
    }

    public List<EmailRecordTable.EmailMessage> getEmailsToUser(String userEmail)
    {
        List<EmailRecordTable.EmailMessage> emails = new ArrayList<>();
        EmailRecordTable table = new EmailRecordTable(getDriver());
        List<Integer> indices = table.getTableIndexesWhereTextAppears("To", userEmail);
        for (int index : indices) emails.add(table.getEmailAtTableIndex(index));
        return emails;
    }

    public List<EmailRecordTable.EmailMessage> filterEmailBySubject(List<EmailRecordTable.EmailMessage> emails, String subject)
    {
        List<EmailRecordTable.EmailMessage> emailsWithSubject = new ArrayList<>();
        for (EmailRecordTable.EmailMessage email : emails)
        {
            if (email.getSubject().contains(subject)) emailsWithSubject.add(email);
        }
        return emailsWithSubject;
    }

    public EmailRecordTable.EmailMessage getEmailBySubject(String subject)
    {
        EmailRecordTable table = new EmailRecordTable(getDriver());
        table.clickSubject(subject);
        return table.getMessage(subject);
    }

    public String buildAdjudicationReviewLink(boolean isAdminReview, String caseNum)
    {
        return WebTestHelper.buildRelativeUrl("adjudication", getCurrentProject(), "adjudicationReview", Maps.of("adjid", caseNum, "isAdminReview", String.valueOf(isAdminReview)));
    }

    public String buildAdjudicationDeterminationLink(String caseNum)
    {
        return WebTestHelper.buildRelativeUrl("adjudication", getCurrentProject(), "adjudicationDetermination", Maps.of("adjid", caseNum));
    }

    public void insertAssayKits()
    {
        if (!isElementPresent(Locator.tagWithText("span", "Manage Adjudication")))
            _test.clickTab("Manage");

        insertAssayKit("002");
        insertAssayKit("1");
        insertAssayKit("104");
        insertAssayKit("105");
        insertAssayKit("108");
        insertAssayKit("109");
        insertAssayKit("204");
        insertAssayKit("206");
        insertAssayKit("207");
        insertAssayKit("208");
        insertAssayKit("209");
        insertAssayKit("210");
        insertAssayKit("211");
        insertAssayKit("301");
        insertAssayKit("303");
        insertAssayKit("306");
        insertAssayKit("402");
        insertAssayKit("403");
        insertAssayKit("406");
        insertAssayKit("408");
    }

    public void insertAssayKit(String kitCode)
    {
        new DataRegionTable("adjkit", this).clickInsertNewRow();
        WebElement select = Locator.name("quf_KitCode").waitForElement(shortWait());
        selectOptionByValue(select, kitCode);
        clickButton("Submit");
    }

    // TODO it would be great to update the existing test to also use the "Set Defaults" link for the supported kits table
    // -- yes, good idea. I'll attempt this
    public void addDefaultAssayTypes()
    {
        if (!isElementPresent(Locator.tagWithText("span", "Manage Adjudication")))
            _test.clickTab("Manage");
        new DataRegionTable("adjassaytype", this).clickHeaderButton("Set Defaults");
    }

    public AdjudicationDeterminationForm beginDetermination(String projectName, String adjudicator, String caseId, int visitRowCount)
    {
        return beginDetermination(projectName, adjudicator, caseId, visitRowCount, false);
    }

    public AdjudicationDeterminationForm beginDetermination(String projectName, String adjudicator, String caseId, int visitRowCount, boolean change)
    {
        _test.impersonate(adjudicator);
        _test.goToProjectHome(projectName);
        _test.clickTab("Case Determination");
        waitForElement(Locator.tagWithClass("div", "gridOne").containing("Active"));
        return goToCaseDetermination(caseId, visitRowCount, change);
    }

    public AdjudicationDeterminationForm goToCaseDetermination(String caseId, int visitRowCount, boolean change)
    {
        AdjudicationDeterminationPage determinationPage = new AdjudicationPage(getDriver()).goToDeterminationsAction(caseId);
        determinationPage.waitForCaseVisitRows(visitRowCount);

        if (change)
            return determinationPage.changeDetermination();
        else
            return determinationPage.makeDetermination();
    }

    public AdminReviewAdjudicationsPage makeDetermination(AdjudicationDeterminationForm determinationForm, AdjudicationDeterminationForm.HivStatus hiv1Status, AdjudicationDeterminationForm.HivStatus hiv2Status)
    {
        return makeDetermination(determinationForm, hiv1Status, hiv2Status, null, null, null, null);
    }

    public AdminReviewAdjudicationsPage makeDetermination(AdjudicationDeterminationForm determinationForm, AdjudicationDeterminationForm.HivStatus hiv1Status, AdjudicationDeterminationForm.HivStatus hiv2Status, String date1, String date2, String comment1, String comment2)
    {
        determinationForm.setHiv1Status(hiv1Status);
        determinationForm.setHiv2Status(hiv2Status);
        if (null != date1)
            determinationForm.setDate1(date1);
        if (null != date2)
            determinationForm.setDate2(date2);
        if (null != comment1)
            determinationForm.setComment1(comment1);
        if (null != comment2)
            determinationForm.setComment2(comment2);

        return determinationForm.submit(hiv1Status == AdjudicationDeterminationForm.HivStatus.INCONCLUSIVE || hiv2Status == AdjudicationDeterminationForm.HivStatus.INCONCLUSIVE);
    }
}
