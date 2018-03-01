/*
 * Copyright (c) 2004-2016 Fred Hutchinson Cancer Research Center
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

package org.labkey.ms2;

import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SimpleDisplayColumn;

/**
 * User: arauch
 * Date: Sep 18, 2004
 * Time: 7:20:25 AM
 */
public class AACoverageColumn extends SimpleDisplayColumn
{
    public AACoverageColumn()
    {
        super();
        setCaption("AA Coverage");
        setFormatString("0.0%");
        setTsvFormatString("0.00");
        setWidth("90");
        setTextAlign("right");
    }

    public Object getValue(RenderContext ctx)
    {
        return ctx.get("AACoverage");
    }

    public Class getValueClass()
    {
        return Double.class;
    }

    public String getName()
    {
        return "AACoverage";
    }
}
