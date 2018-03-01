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

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.components.adjudication.AdjudicationDeterminationForm;

import java.util.Arrays;
import java.util.List;

@Category({CustomModules.class})
public class AdjudicationTestOnlyOne extends AdjudicationAbstractBaseTest
{
    private final String PROJECT_NAME = "Adjudication Test Project HIV-";
    private final String HIV1_ONLY_PROJECT = PROJECT_NAME + "1 ONLY";
    private final String HIV2_ONLY_PROJECT = PROJECT_NAME + "2 ONLY";
    private String ACTIVE_PROJECT = HIV1_ONLY_PROJECT;

    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        _containerHelper.deleteProject(HIV1_ONLY_PROJECT, afterTest);
        _containerHelper.deleteProject(HIV2_ONLY_PROJECT, afterTest);
        _userHelper.deleteUsers(afterTest,
                USER_LAB_PERSONNEL,
                USER_ADJUDICATOR1,
                USER_ADJUDICATOR2);
    }

    @BeforeClass
    public static void createAccounts()
    {
        AdjudicationTestOnlyOne init = (AdjudicationTestOnlyOne) getCurrentTest();

        init.doSetup();
    }

    private void doSetup()
    {
        _userHelper.createUser(USER_LAB_PERSONNEL);
        _userHelper.createUser(USER_ADJUDICATOR1);
        _userHelper.createUser(USER_ADJUDICATOR2);
    }

    @Before
    public void preTest()
    {
        goToHome();
    }

    @Test
    public void testHIV1Only()
    {
        String caseComment = "Case comment " + BaseWebDriverTest.TRICKY_CHARACTERS;
        String[] expected = {"Results", "Non-Reactive", "Reactive"};
        String[] unexpected = {"Band1-GP36", "Band-Foo1"};
        String[] adjudicationUsers = {
                USER_LAB_PERSONNEL + ";" + ROLE_LAB_PERSONNEL + ";",
                USER_ADJUDICATOR1 + ";" + ROLE_ADJUDICATOR + ";1",
                USER_ADJUDICATOR2 + ";" + ROLE_ADJUDICATOR + ";2"
        };

        ACTIVE_PROJECT = HIV1_ONLY_PROJECT;
        _adjTestSupport.createAdjudicationProject(HIV1_ONLY_PROJECT, null, adjudicationUsers, null, "VTN703", "HIV-1 only", null);

        _adjTestSupport.insertAssayKits();
        _adjTestSupport.addDefaultAssayTypes();

        String caseId = _adjTestSupport.createCase(HIV1_ONLY_PROJECT, USER_LAB_PERSONNEL, CASE1_FILE, caseComment, expected, unexpected);

        log("Validate only HIV-1 is shown.");

        AdjudicationDeterminationForm determinationForm = _adjTestSupport.beginDetermination(HIV1_ONLY_PROJECT, USER_ADJUDICATOR1, caseId, 2);
        assertTextNotPresent("HIV-2 Infection Status", "Is this subject HIV-2 infected?");
        assertElementNotPresent("HIV-2 combo box was visible.", Locator.xpath("//input[@name = 'statusHiv2']"));
        assertElementNotPresent(Locator.xpath("//textarea[@name = 'commentHiv2']"));
        determinationForm.cancel();
        assertTextNotPresent("HIV-2 confirmed infection");
        assertTextNotPresent("HIV-2 date of diagnosis");
        assertTextNotPresent("HIV-2 comment");
        stopImpersonating();

        determinationForm = _adjTestSupport.beginDetermination(HIV1_ONLY_PROJECT, USER_ADJUDICATOR2, caseId, 2);
        assertTextNotPresent("HIV-2 Infection Status", "Is this subject HIV-2 infected?");
        assertElementNotPresent("HIV-2 combo box was visible.", Locator.xpath("//input[@name = 'statusHiv2']"));
        assertElementNotPresent(Locator.xpath("//textarea[@name = 'commentHiv2']"));
        determinationForm.cancel();
        assertTextNotPresent("HIV-2 confirmed infection");
        assertTextNotPresent("HIV-2 date of diagnosis");
        assertTextNotPresent("HIV-2 comment");
        stopImpersonating();

    }

    @Test
    public void testHIV2Only()
    {
        String caseComment = "Case comment " + BaseWebDriverTest.TRICKY_CHARACTERS;
        String[] expected = {"Results", "Non-Reactive", "Reactive"};
        String[] unexpected = {"Band1-GP36", "Band-Foo1"};
        String[] adjudicationUsers = {
                USER_LAB_PERSONNEL + ";" + ROLE_LAB_PERSONNEL + ";",
                USER_ADJUDICATOR1 + ";" + ROLE_ADJUDICATOR + ";1",
                USER_ADJUDICATOR2 + ";" + ROLE_ADJUDICATOR + ";2"
        };

        ACTIVE_PROJECT = HIV2_ONLY_PROJECT;
        _adjTestSupport.createAdjudicationProject(HIV2_ONLY_PROJECT, null, adjudicationUsers, null, "VTN703", "HIV-2 only", null);

        _adjTestSupport.insertAssayKits();
        _adjTestSupport.addDefaultAssayTypes();

        String caseId = _adjTestSupport.createCase(HIV2_ONLY_PROJECT, USER_LAB_PERSONNEL, CASE1_FILE, caseComment, expected, unexpected);

        log("Validate only HIV-2 is shown.");

        AdjudicationDeterminationForm determinationForm = _adjTestSupport.beginDetermination(HIV2_ONLY_PROJECT, USER_ADJUDICATOR1, caseId, 2);
        assertTextNotPresent("HIV-1 Infection Status", "Is this subject HIV-1 infected?");
        assertElementNotPresent("HIV-1 combo box was visible.", Locator.xpath("//input[@name = 'statusHiv1']"));
        assertElementNotPresent(Locator.xpath("//textarea[@name = 'commentHiv1']"));
        determinationForm.cancel();
        assertTextNotPresent("HIV-1 confirmed infection");
        assertTextNotPresent("HIV-1 date of diagnosis");
        assertTextNotPresent("HIV-1 comment");
        stopImpersonating();

        determinationForm = _adjTestSupport.beginDetermination(HIV2_ONLY_PROJECT, USER_ADJUDICATOR2, caseId, 2);
        assertTextNotPresent("HIV-1 Infection Status", "Is this subject HIV-1 infected?");
        assertElementNotPresent("HIV-1 combo box was visible.", Locator.xpath("//input[@name = 'statusHiv1']"));
        assertElementNotPresent(Locator.xpath("//textarea[@name = 'commentHiv1']"));
        determinationForm.cancel();
        assertTextNotPresent("HIV-1 confirmed infection");
        assertTextNotPresent("HIV-1 date of diagnosis");
        assertTextNotPresent("HIV-1 comment");
        stopImpersonating();

    }

    @Override
    protected BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    protected String getProjectName()
    {
        return ACTIVE_PROJECT;
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("adjudication");
    }

}