/*
 * Copyright (c) 2007-2008 LabKey Corporation
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

package org.labkey.ms2.protein;

/**
 * User: jeckels
 * Date: Oct 1, 2007
 */
public class CharactersParseActions extends ParseActions
{
    protected String _accumulated;

    public void characters(ParseContext context, char ch[], int start, int len)
    {
        if (context.isIgnorable())
        {
            return;
        }
        _accumulated += new String(ch, start, len);
    }
}
