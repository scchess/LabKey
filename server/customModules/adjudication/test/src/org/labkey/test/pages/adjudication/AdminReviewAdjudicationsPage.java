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
package org.labkey.test.pages.adjudication;

import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.Component;
import org.labkey.test.pages.LabKeyPage;
import org.labkey.test.selenium.LazyWebElement;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.Maps;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.HashMap;
import java.util.Map;

public class AdminReviewAdjudicationsPage extends LabKeyPage<AdminReviewAdjudicationsPage.ElementCache>
{
    public AdminReviewAdjudicationsPage(WebDriver driver)
    {
        super(driver);
        waitForElement(Locators.pageSignal("determinationTablesLoaded"));
        elementCache().assayResults.isDisplayed();
    }

    public static AdminReviewAdjudicationsPage beginAt(WebDriverWrapper test, int adjId, boolean isAdminReview)
    {
        return beginAt(test, test.getCurrentContainerPath(), adjId, isAdminReview);
    }

    public static AdminReviewAdjudicationsPage beginAt(WebDriverWrapper test, String containerPath, int adjId, boolean isAdminReview)
    {
        test.beginAt(WebTestHelper.buildURL("adjudication", containerPath, "adjudicationReview", Maps.of("adjid", Integer.toString(adjId), "isAdminReview", Boolean.toString(isAdminReview))));
        return new AdminReviewAdjudicationsPage(test.getDriver());
    }

    public Summary getSummary()
    {
        return elementCache().getSummary();
    }

    public DeterminationTable getDeterminationTable1()
    {
        return elementCache().getDeterminationTable(1);
    }

    public DeterminationTable getDeterminationTable2()
    {
        return elementCache().getDeterminationTable(2);
    }

    public AdjudicationDeterminationPage changeDetermination()
    {
        clickAndWait(elementCache().changeDeterminationLink);
        return new AdjudicationDeterminationPage(getDriver());
    }

    public AdminReviewAdjudicationsPage verifyReceiptOfDetermination()
    {
        clickAndWait(elementCache().verifyReceiptLink);
        return new AdminReviewAdjudicationsPage(getDriver());
    }

    public String getLabVerificationDate()
    {
        return elementCache().verificationDate.getText();
    }

    public DataRegionTable getCaseDocuments()
    {
        return elementCache().caseDocumentGrid;
    }

    public WebElement getAssayResults()
    {
        return elementCache().assayResults;
    }

    public class Summary extends Component
    {
        private WebElement _componentElement;

        WebElement summaryCaseId = new LazyWebElement(Locator.id("adj"), this);
        WebElement summaryPtid = new LazyWebElement(Locator.id("ptid"), this);
        WebElement summaryStatus = new LazyWebElement(Locator.id("state"), this);
        WebElement summaryCreationDate = new LazyWebElement(Locator.id("casecreate"), this);
        WebElement summaryCompletionDate = new LazyWebElement(Locator.id("casecomplete"), this);
        WebElement summaryComments = new LazyWebElement(Locator.id("comments"), this);
        WebElement editCommentLink = new LazyWebElement(Locator.id("editCaseComments"), this);

        Summary()
        {
            _componentElement = getDriver().findElement(By.id("caseSummary"));
        }

        @Override
        public WebElement getComponentElement()
        {
            return _componentElement;
        }

        public String getCaseId()
        {
            return summaryCaseId.getAttribute("value");
        }

        public String getPtid()
        {
            return summaryPtid.getText();
        }

        public String getStatus()
        {
            return summaryStatus.getText();
        }

        public String getCreationDate()
        {
            return summaryCreationDate.getText();
        }

        public String getCompletionDate()
        {
            return summaryCompletionDate.getText();
        }

        public String getComments()
        {
            return summaryComments.getText();
        }

        public void editComments(String newComment)
        {
            editCommentLink.click();
            WebElement window = waitForElement(Ext4Helper.Locators.window("Edit Comments"));
            setFormElement(Locator.css("textarea").findElement(window), newComment);
            click(Ext4Helper.Locators.windowButton("Edit Comments", "Save Changes"));
            shortWait().until(ExpectedConditions.textToBePresentInElement(summaryComments, newComment));
        }
    }

    public class DeterminationTable extends Component
    {
        private final int _tableNum;
        WebElement _tableEl;

        private WebElement _deter;
        private WebElement _compdt;
        private WebElement _hiv1Inf;
        private WebElement _hiv1Infdt;
        private WebElement _hiv1comm;
        private WebElement _hiv2Inf;
        private WebElement _hiv2Infdt;
        private WebElement _hiv2comm;
        private WebElement _adjor;

        DeterminationTable(int tableNum)
        {
            _tableNum = tableNum;
            _tableEl = Locator.id("determinationTable" + tableNum).findElement(getDriver());

            _deter = new LazyWebElement(Locator.id("deter" + _tableNum), this);
            _compdt = new LazyWebElement(Locator.id("compdt" + _tableNum), this);
            _hiv1Inf = new LazyWebElement(Locator.id("hiv1Inf" + _tableNum), this);
            _hiv1Infdt = new LazyWebElement(Locator.id("hiv1Infdt" + _tableNum), this);
            _hiv1comm = new LazyWebElement(Locator.id("hiv1comm" + _tableNum), this);
            _hiv2Inf = new LazyWebElement(Locator.id("hiv2Inf" + _tableNum), this);
            _hiv2Infdt = new LazyWebElement(Locator.id("hiv2Infdt" + _tableNum), this);
            _hiv2comm = new LazyWebElement(Locator.id("hiv2comm" + _tableNum), this);
            _adjor = new LazyWebElement(Locator.id("adjor" + _tableNum), this);
        }

        @Override
        public WebElement getComponentElement()
        {
            return _tableEl;
        }

        public String getDetermination()
        {
            return _deter.getText();
        }

        public String getCompletionDate()
        {
            return _compdt.getText();
        }

        public String getHiv1InfectionState()
        {
            return _hiv1Inf.getText();
        }

        public String getHiv1InfectionDate()
        {
            return _hiv1Infdt.getText();
        }

        public String getHiv1Comment()
        {
            return _hiv1comm.getText();
        }

        public String getHiv2InfectionState()
        {
            return _hiv2Inf.getText();
        }

        public String getHiv2InfectionDate()
        {
            return _hiv2Infdt.getText();
        }

        public String getHiv2Comment()
        {
            return _hiv2comm.getText();
        }

        public String getAdjudicator()
        {
            return _adjor.getText();
        }
    }

    @Override
    protected ElementCache newElementCache()
    {
        return new ElementCache();
    }

    protected class ElementCache extends LabKeyPage.ElementCache
    {
        private Summary _summary;
        private final Map<Integer, DeterminationTable> _determinationTables = new HashMap<>();

        public Summary getSummary()
        {
            if (_summary == null)
                _summary = new Summary();
            return _summary;
        }

        public DeterminationTable getDeterminationTable(int num)
        {
            if (!_determinationTables.containsKey(num))
                _determinationTables.put(num, new DeterminationTable(num));
            return _determinationTables.get(num);
        }

        protected final DataRegionTable caseDocumentGrid = DataRegionTable.DataRegion(getDriver()).withName("documents").findWhenNeeded(this);

        protected final WebElement assayResults = Locator.id("assayRes").findWhenNeeded(this).withTimeout(WAIT_FOR_JAVASCRIPT);
        protected final WebElement changeDeterminationLink = new LazyWebElement(Locator.linkWithText("Change Determination"), getDriver());
        protected final WebElement verifyReceiptLink = new LazyWebElement(Ext4Helper.Locators.ext4Button("Verify Receipt of Determination"), getDriver());
        protected final WebElement verificationDate = new LazyWebElement(Locator.id("labverifydate"), getDriver());
    }
}