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

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.TestFileUtils;
import org.labkey.test.pages.adjudication.AdministratorDashboardPage;
import org.labkey.test.utils.adjudication.AdjudicationTestSupport;

import java.io.File;
import java.util.Arrays;
import java.util.List;

public abstract class AdjudicationAbstractBaseTest extends BaseWebDriverTest
{
    public static final String USER_READER1 = "reader1@adjudication.test";
    public static final String USER_READER2 = "reader2@adjudication.test";
    public static final String USER_READER3 = "reader3@adjudication.test";
    public static final String USER_LAB_PERSONNEL = "lab.personnel@adjudication.test";
    public static final String USER_INF_MONITOR = "inf.monitor@adjudication.test";
    public static final String USER_DATA_REVIEWER = "data.reviewer@adjudication.test";
    public static final String USER_ADJUDICATOR1 = "adjudicator1@adjudication.test";
    public static final String USER_ADJUDICATOR2 = "adjudicator2@adjudication.test";
    public static final String USER_ADJUDICATOR3 = "adjudicator3@adjudication.test";
    public static final String USER_ADJUDICATOR4 = "adjudicator4@adjudication.test";

    public static final String ROLE_FOLDER_ADMIN = "Folder Administrator";
    public static final String ROLE_ADJUDICATOR = "Adjudicator";
    public static final String ROLE_LAB_PERSONNEL = "Lab Personnel";
    public static final String ROLE_INF_MONITOR = "Infection Monitor";
    public static final String ROLE_DATA_REVIEWER = "Data Reviewer";
    public static final String ROLE_TO_BE_NOTIFIED = "To Be Notified";

    public static final File CASE1_FILE = TestFileUtils.getSampleData("adjudication/VTN703_123456780_02Aug2015.txt");
    public static final String CASE1_PTID = "123456780";
    public static final List<String> CASE1_VISITS = Arrays.asList("1", "2");
    public static final File CASE2_FILE = TestFileUtils.getSampleData("adjudication/VTN703_123456780_03Aug2015.txt");
    public static final String CASE2_PTID = "123456780";
    public static final List<String> CASE2_VISITS = Arrays.asList("10", "11", "101", "102");
    public static final List<String> CASE2_COLL_DATES = Arrays.asList("01AUG2015", "02AUG2015");
    public static final File CASE3_FILE = TestFileUtils.getSampleData("adjudication/VTN703_123456789_25OCT2015.txt");
    public static final String CASE3_PTID = "123456789";
    public static final List<String> CASE3_COLL_DATES = Arrays.asList("01JAN2015");
    public static final List<String> CASE3_VISITS = Arrays.asList("100", "101", "102", "103", "104", "105", "106", "107");
    public static final File CASE4_FILE = TestFileUtils.getSampleData("adjudication/VTN703_123456795_13Mar2015.txt");
    public static final File CASE5_FILE = TestFileUtils.getSampleData("adjudication/VTN703_123456781_03Feb2016.txt");
    public static final File CASE11_FILE = TestFileUtils.getSampleData("adjudication/VTN703_223456781_03Feb2016.txt");
    public static final File CASE12_FILE = TestFileUtils.getSampleData("adjudication/VTN703_323456781_03Feb2016.txt");
    public static final File CASE14_FILE = TestFileUtils.getSampleData("adjudication/VTN703_123456780_30Aug2015.txt");
    public static final File CASE13_FILE = TestFileUtils.getSampleData("adjudication/VTN703_423456781_03Feb2016.txt");
    public static final String CASE5_PTID = "123456781";
    public static final File CASE5_CS_FILE = TestFileUtils.getSampleData("adjudication/CaseSensitivity/VTN703_123456781_03Feb2016.TXT");
    public static final File CASE6_FILE =  TestFileUtils.getSampleData("adjudication/VTN703_867530900_23Feb2016.txt");
    public static final String CASE6_PTID = "867530900";
    public static final List<String> CASE6_VISITS = Arrays.asList("1");
    public static final File CASE7_FILE = TestFileUtils.getSampleData("adjudication/VTN703_867530911_29Feb2016.txt");
    public static final String CASE7_PTID = "867530911";
    public static final File CASE7_CS_FILE = TestFileUtils.getSampleData("adjudication/CaseSensitivity/VTN703_867530911_29Feb2016.TXT");
    public static final File UPDATE_CASE_ORIGINAL = TestFileUtils.getSampleData("adjudication/caseUpdate/original/VTN703_100000001_17NOV2016.txt");
    public static final File UPDATE_CASE_UPDATE = TestFileUtils.getSampleData("adjudication/caseUpdate/update/VTN703_100000001_17NOV2016.txt");
    public static final List<String> UPDATE_CASE_VISITS = Arrays.asList("100", "101", "102", "103", "104", "105", "106", "107");
    public static final List<String> UPDATE_CASE_COLL_DATES = Arrays.asList("01OCT2016", "07OCT2016", "14OCT2016", "21OCT2016", "25OCT2016", "01NOV2016", "07NOV2016", "15NOV2016");

    public static final File CASE8_FILE = TestFileUtils.getSampleData("adjudication/VTN703_867530901_23Feb2016.txt");
    public static final String CASE8_PTID = "867530901";

    public static  final File CASE1_BADFILE = TestFileUtils.getSampleData("adjudication/VTN703_999999999_25OCT2015.txt");
    public static final File CASE2_BADFILE = TestFileUtils.getSampleData("adjudication/VTN503_123456781_25APR2015.txt");
    public static final File CASE3_BADFILE = TestFileUtils.getSampleData("adjudication/VTN703_999999999_27APR1955.txt");

    public static final String NO_PERMISSIONS_MSG = "You do not have permission to view this dashboard.";
    public static final String NO_PERMISSIONS_MSG2 = "You do not have permission to view this wizard.";

    public static final String TAB_OVERVIEW = "Overview";
    public static final String TAB_CASE_DETERMINATION_ID = "Adjudication";
    public static final String TAB_CASE_DETERMINATION = "Case Determination";
    public static final String TAB_ADMIN_DASHBOARD = "Administrator Dashboard";
    public static final String TAB_INFECTION_MONITOR = "Infection Monitor";
    public static final String TAB_UPLOAD = "Upload";
    public static final String TAB_MANAGE = "Manage";

    public final AdjudicationTestSupport _adjTestSupport = new AdjudicationTestSupport(this);

    public AdministratorDashboardPage goToAdminDashboard()
    {
        clickTab(TAB_ADMIN_DASHBOARD);
        return new AdministratorDashboardPage(this);
    }
}
