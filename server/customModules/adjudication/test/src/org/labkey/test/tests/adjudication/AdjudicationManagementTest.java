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
package org.labkey.test.tests.adjudication;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.components.adjudication.AdjudicatorTeamMemberForm;
import org.labkey.test.components.adjudication.AdminSettingsForm;
import org.labkey.test.components.ext4.Window;
import org.labkey.test.util.ApiPermissionsHelper;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.LoggedParam;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PortalHelper;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.labkey.test.Locators.pageSignal;

@Category({CustomModules.class})
public class AdjudicationManagementTest extends AdjudicationAbstractBaseTest
{
    @BeforeClass
    public static void setupProject()
    {
        AdjudicationManagementTest init = (AdjudicationManagementTest) getCurrentTest();
        init.doSetup();
    }

    private void doSetup()
    {
        _userHelper.createUser(USER_READER1);
        _userHelper.createUser(USER_LAB_PERSONNEL);
        _userHelper.createUser(USER_INF_MONITOR);
        _userHelper.createUser(USER_DATA_REVIEWER);
        _userHelper.createUser(USER_ADJUDICATOR1);
        _userHelper.createUser(USER_ADJUDICATOR2);

        _adjTestSupport.createAdjudicationProject(getProjectName(), null, null, null, "TEST", null, null);
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
        clickTab("Manage");

        // make sure AdjudicationUser table is clear
        DataRegionTable table = new DataRegionTable("adjuser", this.getDriver());
        if (table.getDataRowCount() > 0)
        {
            table.checkAll();
            doAndWaitForPageToLoad(() -> {
                table.clickHeaderButton("Delete");
                acceptAlert();
            });
        }

        // start each test with team count set to one
        AdminSettingsForm adminSettingsForm = new AdminSettingsForm(this.getDriver());
        if (adminSettingsForm.getNumberOfTeams() != 1)
        {
            adminSettingsForm.setNumberOfTeams("1");
        }
    }

    @Test
    public void testTeamMemberAssignment()
    {
        AdminSettingsForm adminSettingsForm = new AdminSettingsForm(this.getDriver());
        adminSettingsForm.setNumberOfTeams("2");

        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR1, ROLE_ADJUDICATOR);
        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR2, ROLE_ADJUDICATOR);

        clickTab("Manage");
        AdjudicatorTeamMemberForm teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.assignMember(USER_ADJUDICATOR1, 1, false, true);
        teamMemberForm.assignMember(USER_ADJUDICATOR2, 1, true, true);
        teamMemberForm.save(true);
        Window msgWindow = new Window("Warning", this.getDriver());
        assertTrue(msgWindow.getBody().contains("Team 2 does not have any adjudicators assigned."));
        msgWindow.clickButton("No", 0);

        teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.assignMember(USER_ADJUDICATOR2, 2, false, true);
        msgWindow = new Window("Error", this.getDriver());
        assertTrue(msgWindow.getBody().contains("The selected adjudicator is already assigned to a team."));
        msgWindow.clickButton("OK", 0);

        teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.clearAssignedMember(1, true);
        teamMemberForm.assignMember(USER_ADJUDICATOR2, 2, false, true);
        teamMemberForm.save(false);

        teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.clearAssignedMember(1, false);
        teamMemberForm.clearAssignedMember(2, false);
        teamMemberForm.save(true);
        msgWindow = new Window("Warning", this.getDriver());
        assertTrue(msgWindow.getBody().contains("Team 1 does not have any adjudicators assigned."));
        assertTrue(msgWindow.getBody().contains("Team 2 does not have any adjudicators assigned."));
        msgWindow.clickButton("No", 0);

        teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.assignMember(USER_ADJUDICATOR1, 1, false, false);
        teamMemberForm.assignMember(USER_ADJUDICATOR2, 2, false, true);
        teamMemberForm.save(true);
        msgWindow = new Window("Error", this.getDriver());
        assertTrue(msgWindow.getBody().contains("Team 1 must have at least one adjudicator set to receive notifications."));
        msgWindow.clickButton("OK", 0);

        teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.setNotificationState(1, false, true);
        teamMemberForm.setNotificationState(2, false, false);
        teamMemberForm.save(true);
        msgWindow = new Window("Error", this.getDriver());
        assertTrue(msgWindow.getBody().contains("Team 2 must have at least one adjudicator set to receive notifications."));
        msgWindow.clickButton("OK", 0);
    }

    @Test
    public void testTeamNumberChange()
    {
        AdminSettingsForm adminSettingsForm = new AdminSettingsForm(this.getDriver());

        int numTeams = 1;
        assertEquals("Expected the test to start with one team", numTeams, adminSettingsForm.getNumberOfTeams());
        assertEquals(numTeams * 2, new AdjudicatorTeamMemberForm(getDriver()).getNumberOfTeamMemberPositions());

        // verify that the number of team member positions updates according to team number setting
        for (numTeams = 2; numTeams < 6; numTeams++)
        {
            adminSettingsForm.setNumberOfTeams(""+numTeams);
            assertEquals(numTeams, adminSettingsForm.getNumberOfTeams());
            assertEquals(numTeams * 2, new AdjudicatorTeamMemberForm(getDriver()).getNumberOfTeamMemberPositions());
        }
    }

    @Test
    public void testAdjudicatorRoleChange()
    {
        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR2, ROLE_ADJUDICATOR);
        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR2, ROLE_ADJUDICATOR);
        assertTextPresent("User already has a role in this container.");
        clickButton("Cancel", "Adjudication Users");

        clickTab("Manage");
        // verify that deleting an adjudicator user role removes the assignment
        AdjudicatorTeamMemberForm teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.assignMember(USER_ADJUDICATOR2, 1, false, true);
        teamMemberForm.save(false);
        assertEquals(1, getAdjudicationTeamUserTableCount());
        DataRegionTable table = new DataRegionTable("adjuser", this.getDriver());
        table.checkAll();
        table.clickHeaderButton("Delete");
        acceptAlert();
        assertEquals(0, getAdjudicationTeamUserTableCount());

        // verify that changing user role removes team assignment
        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR2, ROLE_ADJUDICATOR);
        clickTab("Manage");
        teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.assignMember(USER_ADJUDICATOR2, 1, false, true);
        teamMemberForm.save(false);
        assertEquals(1, getAdjudicationTeamUserTableCount());
        DataRegionTable adjUsers = new DataRegionTable("adjuser", getDriver());
        adjUsers.clickEditRow(0);
        selectOptionByText(Locator.name("quf_RoleId"), ROLE_TO_BE_NOTIFIED);
        clickButton("Submit");
        assertEquals(0, getAdjudicationTeamUserTableCount());
    }

    private int getAdjudicationTeamUserTableCount()
    {
        pushLocation();
        beginAt(WebTestHelper.buildURL("query", getCurrentContainerPath(), "executeQuery", Maps.of("schemaName", "adjudication", "query.queryName", "AdjudicationTeamUser")));
        DataRegionTable table = new DataRegionTable("query", this.getDriver());
        int count = table.getDataRowCount();
        popLocation();
        return count;
    }

    @Test
    public void testAdjudicationRoleAccess()
    {
        ApiPermissionsHelper apiPermissionsHelper = new ApiPermissionsHelper(this);

        // setup a set of users/roles to verify which tabs they see and which webparts they can/should have access to see
        List<AdjudicationRole> testRoles = new ArrayList<>();

        AdjudicationRole role = new AdjudicationRole(false, getCurrentUser(), "Admin",
                Arrays.asList(TAB_OVERVIEW, TAB_ADMIN_DASHBOARD, TAB_INFECTION_MONITOR, TAB_MANAGE));
        role._allowAdminTab = true;
        role._allowManageTab = true;
        testRoles.add(role);

        apiPermissionsHelper.setUserPermissions(USER_READER1, "Reader");
        role = new AdjudicationRole(true, USER_READER1, "Reader",
                Collections.emptyList());
        testRoles.add(role);

        _adjTestSupport.insertAdjudicatorUser(USER_LAB_PERSONNEL, ROLE_LAB_PERSONNEL);
        role = new AdjudicationRole(true, USER_LAB_PERSONNEL, ROLE_LAB_PERSONNEL,
                Arrays.asList(TAB_OVERVIEW, TAB_UPLOAD, TAB_ADMIN_DASHBOARD));
        role._allowAdminTab = true;
        role._allowUploadTab = true;
        testRoles.add(role);

        _adjTestSupport.insertAdjudicatorUser(USER_INF_MONITOR, ROLE_INF_MONITOR);
        role = new AdjudicationRole(true, USER_INF_MONITOR, ROLE_INF_MONITOR,
                Arrays.asList(TAB_OVERVIEW, TAB_ADMIN_DASHBOARD, TAB_INFECTION_MONITOR));
        role._allowAdminTab = true;
        testRoles.add(role);

        _adjTestSupport.insertAdjudicatorUser(USER_DATA_REVIEWER, ROLE_DATA_REVIEWER);
        role = new AdjudicationRole(true, USER_DATA_REVIEWER, ROLE_DATA_REVIEWER,
                Arrays.asList(TAB_OVERVIEW, TAB_ADMIN_DASHBOARD));
        role._allowAdminTab = true;
        testRoles.add(role);

        _adjTestSupport.insertAdjudicatorUser(USER_ADJUDICATOR1, ROLE_ADJUDICATOR);
        role = new AdjudicationRole(true, USER_ADJUDICATOR1, ROLE_ADJUDICATOR,
                Arrays.asList(TAB_OVERVIEW, TAB_CASE_DETERMINATION));
        role._allowAdjudicationTab = true;
        testRoles.add(role);

        clickTab("Manage");
        // in order to verify adjudicator role, need to assign to a team
        AdjudicatorTeamMemberForm teamMemberForm = new AdjudicatorTeamMemberForm(this.getDriver());
        teamMemberForm.assignMember(USER_ADJUDICATOR1, 1, false, true);
        teamMemberForm.save(false);

        // Pausing the jscript error checking because some roles won't have permissions to some pages which cause a null object error.
        pauseJsErrorChecker();

        // iterate through the specified users/roles and impersonate them to verify access
        for (AdjudicationRole testRole : testRoles)
        {
            if (testRole._requiresImpersonation)
                impersonate(testRole._user);

            goToProjectHome();

            List<String> tabs = new ArrayList<>();
            for (String tabText : getTexts(Locators.folderTab.findElements(getDriver())))
            {
                // admins have two extra "" tabs because of addTab and editTab
                tabText = tabText != null ? tabText.trim() : "";
                if (tabText.length() > 0)
                    tabs.add(tabText);
            }
            assertEquals("Wrong tabs visible for " + testRole._roleName, testRole._expectedTabs, tabs);

            verifyOverviewTabPermissions();
            verifyAdjudicationTabPermissions(testRole._allowAdjudicationTab);
            verifyAdminTabPermissions(testRole._allowAdminTab);
            verifyUploadTabPermissions(testRole._allowUploadTab);
            verifyManageTabPermissions(testRole._allowManageTab);

            if (testRole._requiresImpersonation)
                stopImpersonating();
        }

        resumeJsErrorChecker();

    }

    private List<String> getWebPartTitles()
    {
        return PortalHelper.Locators.webPartTitle().findElements(getDriver()).stream().map(el -> el.getText().trim()).collect(Collectors.toList());
    }

    @LogMethod(quiet = true)
    private void verifyOverviewTabPermissions()
    {
        beginAtTab(TAB_OVERVIEW);
        assertEquals("Wrong webparts for Overview tab",
                Arrays.asList("Wiki"),
                getWebPartTitles());
    }

    @LogMethod(quiet = true)
    private void verifyAdjudicationTabPermissions(boolean hasPermission)
    {
        beginAtTab(TAB_CASE_DETERMINATION_ID);

        List<String> webpartTitles = getWebPartTitles();
        // Notifications webpart is only shown if a notification exists for this user
        List<String> expectedTitles = webpartTitles.size() == 3 ? Arrays.asList("Notifications", "Dashboard", "Case Summary Report")
                : Arrays.asList("Dashboard", "Case Summary Report");
        assertEquals("Wrong webparts for Case Determination tab", expectedTitles, webpartTitles);

        if (hasPermission)
            waitForElement(pageSignal("adjudicationDashboardComplete"));
        else
            waitForElement(Locator.tagWithText("div", NO_PERMISSIONS_MSG));

    }

    @LogMethod(quiet = true)
    private void verifyAdminTabPermissions(boolean hasPermission)
    {
        beginAtTab(TAB_ADMIN_DASHBOARD);

        List<String> webpartTitles = getWebPartTitles();
        // Notifications webpart is only shown if a notification exists for this user
        List<String> expectedTitles = webpartTitles.size() == 3 ? Arrays.asList("Notifications", "Dashboard", "Case Summary Report")
                : Arrays.asList("Dashboard", "Case Summary Report");
        assertEquals("Wrong webparts for Administrator Dashboard tab", expectedTitles, webpartTitles);

        if (hasPermission)
            waitForElement(pageSignal("adjudicationDashboardComplete"));
        else
            waitForElement(Locator.tagWithText("div", NO_PERMISSIONS_MSG));

    }

    @LogMethod(quiet = true)
    private void verifyUploadTabPermissions(boolean hasPermission)
    {
        beginAtTab(TAB_UPLOAD);

        List<String> webpartTitles = getWebPartTitles();
        assertEquals("Wrong webparts for Upload tab", Arrays.asList("Upload Wizard"), webpartTitles);

        if (hasPermission)
            waitForElement(Locator.tagWithText("td", "Step 1: Upload Adjudication Data File"));
        else
            waitForElement(Locator.tagWithText("div", NO_PERMISSIONS_MSG2));
    }

    @LogMethod(quiet = true)
    private void verifyManageTabPermissions(boolean hasPermission)
    {
        beginAtTab(TAB_MANAGE);

        List<String> webpartTitles = getWebPartTitles();
        List<String> expectedTitles = hasPermission
                ? Arrays.asList("Manage Adjudication", "Adjudication Users", "Adjudicator Team Members", "Supported Assay Kits", "Assay Types")
                : Collections.emptyList();
        assertEquals("Wrong webparts for Manage tab", expectedTitles, webpartTitles);
    }

    @LogMethod(quiet = true)
    private void beginAtTab(@LoggedParam String tabId)
    {
        tabId = tabId.replace(" ", "");
        beginAt(WebTestHelper.buildURL("project", getCurrentContainerPath(), "begin", Maps.of("pageId", tabId)));
    }

    @Override
    protected BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    protected String getProjectName()
    {
        return "AdjudicationManagementTest Project";
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("adjudication");
    }

    class AdjudicationRole
    {
        boolean _requiresImpersonation;
        String _user;
        String _roleName;
        List<String> _expectedTabs;
        boolean _allowAdjudicationTab;
        boolean _allowAdminTab;
        boolean _allowUploadTab;
        boolean _allowManageTab;

        AdjudicationRole(boolean requiresImpersonation, String user, String roleName, List<String> expectedTabs)
        {
            _requiresImpersonation = requiresImpersonation;
            _user = user;
            _roleName = roleName;
            _expectedTabs = expectedTabs;
        }
    }
}
