/*
 * Copyright (c) 2008-2013 LabKey Corporation
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

package org.labkey.api.reports.chart;

/**
 * User: Karl Lum
 * Date: Mar 6, 2008
 */
public class RenderInfo implements ChartRenderInfo
{
    private String _imageMapCallback;
    private String[] _imageMapCallbackColumns;

    public RenderInfo(String imageMapCallback)
    {
        this(imageMapCallback, new String[0]);
    }

    public RenderInfo(String imageMapCallback, String[] imageMapCallbackColumns)
    {
        _imageMapCallback = imageMapCallback;
        _imageMapCallbackColumns = imageMapCallbackColumns;
    }

    public String getImageMapCallback()
    {
        return _imageMapCallback;
    }

    public String[] getImageMapCallbackColumns()
    {
        return _imageMapCallbackColumns != null ? _imageMapCallbackColumns : new String[0];
    }
}
