/*
 * Copyright (c) 2016 LabKey Corporation
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

package org.labkey.cnprc_ehr;

import org.labkey.api.action.SimpleRedirectAction;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Container;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.NavTree;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

public class CNPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(CNPRC_EHRController.class);
    public static final String NAME = "cnprc_ehr";

    public CNPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }

    public static class ObservationCodeForm
    {
        private String _obsCode;

        public String getObsCode()
        {
            return _obsCode;
        }

        public void setObsCode(String obsCode)
        {
            _obsCode = obsCode;
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class ObservationCodeDetailAction extends SimpleRedirectAction<ObservationCodeForm>
    {
        @Override
        public ActionURL getRedirectURL(ObservationCodeForm form) throws Exception
        {
            Container c = getViewContext().getContainer();
            String encodedContainerPath = PageFlowUtil.encode(c.getPath());
            ActionURL url = new ActionURL("query" + encodedContainerPath + "%2FdetailsQueryRow.view");
            url.addParameter("schemaName", "cnprc_ehr");
            url.addParameter("query.queryName", "observation_type_snomed");
            url.addParameter("obsCode", form.getObsCode());
            return url;
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class ConfirmObservationAction extends SimpleViewAction
    {
        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return null;
        }

        @Override
        public ModelAndView getView(Object o, BindException errors) throws Exception
        {
            String pid = getViewContext().getRequest().getParameter("id");
            return new HtmlView("Participant Id: " + pid +
                    "<div>Animal Details</div>" +
                    "<div>Appetite:<select><option>Lookup</option></select> </div>" +
                    "<div>Hydration:<select><option>Lookup</option></select> </div>" +
                    "<div>Stool:<select><option>Lookup</option></select> </div>" +
                    "<div>Remark:<textarea></textarea></div>");

        }
    }
}