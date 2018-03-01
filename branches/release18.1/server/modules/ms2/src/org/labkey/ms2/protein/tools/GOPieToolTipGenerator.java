/*
 * Copyright (c) 2005-2010 Fred Hutchinson Cancer Research Center
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

package org.labkey.ms2.protein.tools;

import org.jfree.chart.labels.PieToolTipGenerator;
import org.jfree.data.general.PieDataset;

/**
 * User: tholzman
 * Date: Oct 24, 2005
 * Time: 3:40:25 PM
 */
public class GOPieToolTipGenerator implements PieToolTipGenerator
{

    public String generateToolTip(PieDataset pieDataset, Comparable comparable)
    {
        String skey = (String) comparable;
        if (skey == null) return null;
        if (skey.equalsIgnoreCase("other")) return "Others: too few members for individual slices";
        if (skey.length() < 10 || !skey.startsWith("GO:")) return skey;
        String acc = skey.substring(0, 10).trim();
        String tip = null;
        try
        {
            tip = ProteinDictionaryHelpers.getGODefinitionFromAcc(acc);
        }
        catch (Exception e)
        {
        }
        if (tip == null) return "'" + skey + "' is an unknown or defunct category";
        return skey + ": " + tip;
    }
}
