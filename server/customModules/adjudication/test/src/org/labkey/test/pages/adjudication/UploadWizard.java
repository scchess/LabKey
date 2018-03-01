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

import org.junit.Assert;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.components.Component;
import org.labkey.test.components.WebPart;
import org.labkey.test.selenium.LazyWebElement;
import org.labkey.test.util.Maps;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.labkey.test.BaseWebDriverTest.WAIT_FOR_JAVASCRIPT;

public class UploadWizard extends BodyWebPart<UploadWizard.ElementCache>
{
    public UploadWizard(BaseWebDriverTest test)
    {
        super(test.getDriver(), "Upload Wizard", 0);
    }

    public static UploadWizard beginAt(BaseWebDriverTest test)
    {
        return beginAt(test, test.getCurrentContainerPath());
    }

    public static UploadWizard beginAt(BaseWebDriverTest test, String containerPath)
    {
        test.beginAt(WebTestHelper.buildURL("project", containerPath, "begin", Maps.of("pageId", "Upload")));
        return new UploadWizard(test);
    }

    public Step1 startWizard()
    {
        return new Step1();
    }

    public String getStatus()
    {
        return elementCache().status.getText();
    }

    private String waitForStatus(String status)
    {
        getWrapper().shortWait().until(ExpectedConditions.textToBePresentInElement(elementCache().status, status));
        return elementCache().status.getText();
    }

    @Override
    protected ElementCache newElementCache()
    {
        return new ElementCache();
    }

    protected class ElementCache extends WebPart.ElementCache
    {
        public WebElement nextButton = new LazyWebElement(Locator.id("nextButton"), getComponentElement());
        public WebElement finishButton = new LazyWebElement(Locator.id("finishButton"), getComponentElement());
        public WebElement status = new LazyWebElement(Locator.id("status"), getComponentElement());
    }

    public class Step1 extends Component
    {
        private final WebElement _stepDiv;
        private final WebElement _uploadInput;

        private Step1()
        {
            _stepDiv = Locator.id("step1Div").withText().findElement(UploadWizard.this.getComponentElement());
            _uploadInput = Locator.tagWithName("input", "file").waitForElement(this, 3000);
        }

        @Override
        public WebElement getComponentElement()
        {
            return _stepDiv;
        }

        public int uploadDataFile(File adjudicationDataFile)
        {
            getWrapper().setFormElement(_uploadInput, adjudicationDataFile);
            String status = waitForStatus("Data file loaded successfully");
            Pattern numberPattern = Pattern.compile("\\d+");
            Matcher statusMatcher = numberPattern.matcher(status);
            if(!statusMatcher.find())
                Assert.fail("Unable to parse upload message: " + status);

            return Integer.parseInt(statusMatcher.group(0));
        }

        public void uploadDataFileExpectingError(File adjudicationDataFile, String expectedError)
        {
            getWrapper().setFormElement(_uploadInput, adjudicationDataFile);
            getWrapper().waitForText("Upload Failed");
            getWrapper().assertTextPresent(expectedError);
            getWrapper()._ext4Helper.clickWindowButton("Upload Failed", "OK", WAIT_FOR_JAVASCRIPT, 0);
        }

        public int uploadDataFileWithExtraField(File adjudicationDataFile, String expectedError, boolean continueUpload)
        {
            getWrapper().setFormElement(_uploadInput, adjudicationDataFile);
            getWrapper().waitForText("Warning");
            getWrapper().assertTextPresent(expectedError);
            if(continueUpload)
            {
                getWrapper()._ext4Helper.clickWindowButton("Warning", "Yes", 0, 0);
                String status = waitForStatus("Data file loaded successfully");
                Pattern numberPattern = Pattern.compile("\\d+");
                Matcher statusMatcher = numberPattern.matcher(status);
                if(!statusMatcher.find())
                    Assert.fail("Unable to parse upload message: " + status);

                return Integer.parseInt(statusMatcher.group(0));
            }
            else
            {
                getWrapper()._ext4Helper.clickWindowButton("Warning", "No", 0, 0);
                getWrapper().waitForTextToDisappear("Data file loaded successfully");
                return 0;
            }
        }

        public Step2 clickNext()
        {
            UploadWizard.this.elementCache().nextButton.click();
            return new Step2();
        }
    }

    public class Step2 extends Component
    {
        private final WebElement _stepDiv;

        private Step2()
        {
            _stepDiv = Locator.id("step2Div").withText().waitForElement(UploadWizard.this.getComponentElement(), WAIT_FOR_JAVASCRIPT);
        }

        @Override
        public WebElement getComponentElement()
        {
            return _stepDiv;
        }

        public String getPtid()
        {
            return findElement(Locator.id("ptidcell")).getText();
        }

        public List<String> getVisits()
        {
            return Arrays.asList(findElement(Locator.id("visitscell")).getText().split(", "));
        }

        public Step2 setCaseComment(String comment)
        {
            getWrapper().setFormElement(findElement(Locator.id("caseComment")), comment);
            return this;
        }

        public void clickMerge()
        {
            clickMerge(false);
        }

        public void clickMerge(boolean afterCaseCompletion)
        {
            if(afterCaseCompletion)
            {
                getWrapper().waitForElement(Locator.xpath("//div//b[text()='completed']"));
                getWrapper().clickButton("Merge", 0);
                getWrapper().waitForElement(Locator.tagContainingText("div", "New data file uploaded. Merging with a completed adjudication case..."));
            }
            else
            {
                getWrapper().waitForElement(Locator.tagContainingText("div", "An adjudication case already exists with this file name."));
                getWrapper().clickButton("Merge", 0);
                getWrapper().waitForElement(Locator.tagContainingText("div", "New data file uploaded. Merging with an adjudication case..."));
            }


        }

        public void clickExitWizard()
        {
            getWrapper().clickButton("Exit Wizard", 0);
        }

        public String getStatusText()
        {
            return getWrapper().getText(Locator.xpath("//div[@id='status']"));
        }

        public Step3 clickNext()
        {
            UploadWizard.this.elementCache().nextButton.click();
            return new Step3();
        }
    }

    public class Step3 extends Component
    {
        private final WebElement _stepDiv;

        private Step3()
        {
            waitForStatus("Upload optional file(s)...");
            _stepDiv = Locator.id("step3Div").withText().waitForElement(UploadWizard.this.getComponentElement(), WAIT_FOR_JAVASCRIPT);
        }

        @Override
        public WebElement getComponentElement()
        {
            return _stepDiv;
        }

        public void uploadOptionalFile(File additionalFile, int rowIndex, String assayType, int visitNum)
        {
            Locator.XPathLocator td = Locator.tagWithText("td", additionalFile.getName());
            getWrapper().doAndWaitForPageSignal(() ->
                Locator.css("a[id='fillButton" + rowIndex + "']").waitForElement(this, WAIT_FOR_JAVASCRIPT).click(), "optionalUpload");
            getWrapper().setFormElement(Locator.name("quf_File"), additionalFile);
            getWrapper()._ext4Helper.clickWindowButton("Insert Optional File for Visit " + visitNum + " " + assayType, "Upload", 0, 0);
            td.waitForElement(this, WAIT_FOR_JAVASCRIPT);
        }

        public Step4 clickNext()
        {
            UploadWizard.this.elementCache().nextButton.click();
            return new Step4();
        }
    }

    public class Step4 extends Component
    {
        private final WebElement _stepDiv;

        private Step4()
        {
            _stepDiv = Locator.id("step4Div").withText().waitForElement(UploadWizard.this.getComponentElement(), WAIT_FOR_JAVASCRIPT);
        }

        @Override
        public WebElement getComponentElement()
        {
            return _stepDiv;
        }

        public Map<String, String> getCaseDetails()
        {
            List<String> detailKeys = getWrapper().getTexts(findElements(Locator.css("tr > td:nth-of-type(1)")));
            List<String> detailValues = getWrapper().getTexts(findElements(Locator.css("tr > td:nth-of-type(2)")));
            Map<String, String> details = new HashMap<>();
            if (detailKeys.size() != detailValues.size())
                throw new IllegalStateException("Error collecting case details");
            Assert.assertEquals("Unexpected case details", CaseDetail.strValues(), new HashSet<>(detailKeys));
            for (int i = 0; i < detailKeys.size(); i++)
            {
                details.put(detailKeys.get(i), detailValues.get(i));
            }
            return details;
        }

        public AdminReviewAdjudicationsPage clickFinish()
        {
            getWrapper().clickAndWait(UploadWizard.this.elementCache().finishButton);
            return new AdminReviewAdjudicationsPage(getDriver());
        }
    }

    public enum CaseDetail
    {
        FILE_NAME("Uploaded File Name"),
        CASE_ID("CaseId"),
        PTID("ParticipantId"),
        VISIT_COUNT("Total Visits"),
        ELISA_COUNT("ELISA Results"),
        //MULTISPOT_COUNT("MULTISPOT Results"),
        WB_COUNT("Western Blot Results"),
        RNAPCR_COUNT("RNA PCR Results"),
        DNAPCR_COUNT("DNA PCR Results"),
        GEENIUS_COUNT("Geenius Results"),
        NUCLEIC_ACID_COUNT("Total Nucleic Acid Results"),
        OPENDISC_COUNT("Open Discretionary Results"),
        COMMENT("Comment");

        private final String _label;

        CaseDetail(String label)
        {
            _label = label;
        }

        public static CaseDetail fromString(String label)
        {
            for (CaseDetail cd : values())
            {
                if (cd._label.equalsIgnoreCase(label))
                    return cd;
            }
            throw new IllegalArgumentException("No such case detail: " + label);
        }

        public static Set<String> strValues()
        {
            Set<String> strValues = new HashSet<>();
            for (CaseDetail cd : values())
            {
                strValues.add(cd._label);
            }
            return strValues;
        }

        @Override
        public String toString()
        {
            return _label;
        }
    }
}