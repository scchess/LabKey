/*
 * Copyright (c) 2007-2014 LabKey Corporation
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

package org.labkey.api.gwt.client.ui;

import com.google.gwt.user.client.rpc.AsyncCallback;
import org.labkey.api.gwt.client.model.GWTChart;
import org.labkey.api.gwt.client.model.GWTChartRenderer;

import java.util.List;

/**
 * User: Karl Lum
 * Date: Dec 3, 2007
 */
public interface ChartServiceAsync 
{
    void getChart(int id, AsyncCallback async);

    void saveChart(GWTChart chart, AsyncCallback<String> async);

    void getDisplayURL(GWTChart chart, AsyncCallback<String> async);
    
    void getChartRenderers(GWTChart chart, AsyncCallback<List<GWTChartRenderer>> async);
}
