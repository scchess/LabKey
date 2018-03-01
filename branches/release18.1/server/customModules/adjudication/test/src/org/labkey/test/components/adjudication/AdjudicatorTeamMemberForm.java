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
package org.labkey.test.components.adjudication;

import org.labkey.test.Locator;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.components.ext4.Checkbox;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.PortalHelper;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import static org.labkey.test.components.ext4.Checkbox.Ext4Checkbox;
import static org.labkey.test.components.ext4.Window.Window;

public class AdjudicatorTeamMemberForm extends BodyWebPart
{
    protected final Locator saveButtonLoc = Locator.tagWithClass("a", "team-member-save");
    protected final Locator teamMemberPosition = Locator.tagWithClass("table", "team-assignment-position");

    public AdjudicatorTeamMemberForm(WebDriver driver)
    {
        super(driver, "Adjudicator Team Members");
    }

    public void assignMember(String userEmail, int adjTeam, boolean asBackup, boolean toNotify)
    {
        getWrapper().waitForElement(getTeamMemberCombo(adjTeam, asBackup));
        getWrapper()._ext4Helper.selectComboBoxItem(getTeamMemberCombo(adjTeam, asBackup), userEmail);
        setNotificationState(adjTeam, asBackup, toNotify);
    }

    public void clearAssignedMember(int adjTeam, boolean isBackup)
    {
        getWrapper().click(getTeamMemberCombo(adjTeam, isBackup).append("//div[contains(@class, 'x4-trigger-index-1')]"));
    }

    public void clearAllAssignedMembers()
    {
        boolean haveRemovedMember = false;
        for (int i = 0; i < getNumberOfTeamMemberPositions(); i++)
        {
            if (getWrapper().getFormElement(Locator.name("team-assignment-" + i)) != null)
            {
                clearAssignedMember((i+1)/2, i % 2 == 1);
                haveRemovedMember = true;
            }
        }
        save(haveRemovedMember);
        if (haveRemovedMember)
            Window(getDriver()).withTitle("Warning").waitFor().clickButton("Yes", 10000);
    }

    public void setNotificationState(int adjTeam, boolean isBackup, boolean toNotify)
    {
        Checkbox checkbox = Ext4Checkbox().withLabel("Send notifications").index(getMemberPosition(adjTeam, isBackup)).find(this);
        checkbox.set(toNotify);
    }

    public void save(boolean warningExpected)
    {
        final WebElement saveButton = saveButtonLoc.findElement(this);
        if (warningExpected)
            saveButton.click();
        else
            getWrapper().clickAndWait(saveButton);
    }

    private Locator.XPathLocator getTeamMemberCombo(int adjTeam, boolean isBackup)
    {
        return Ext4Helper.Locators.formItemWithInputNamed("team-assignment-" + getMemberPosition(adjTeam, isBackup));
    }

    private int getMemberPosition(int adjTeam, boolean asBackup)
    {
        return ((adjTeam - 1) * 2) + (asBackup ? 1 : 0);
    }

    public int getNumberOfTeamMemberPositions()
    {
        return teamMemberPosition.waitForElements(this, 10000).size();
    }
}
