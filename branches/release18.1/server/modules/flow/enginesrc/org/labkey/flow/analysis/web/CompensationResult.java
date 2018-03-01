/*
 * Copyright (c) 2006-2008 LabKey Corporation
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

package org.labkey.flow.analysis.web;

import org.labkey.flow.analysis.web.FCSAnalyzer;

import java.util.List;
import java.util.Collections;
import java.util.ArrayList;
import java.net.URI;

public class CompensationResult
{
    URI uri;
    CompSign sign;
    String channelName;

    List<FCSAnalyzer.Result> results;

    public CompensationResult(CompSign sign, String channelName, URI uri)
    {
        this.sign = sign;
        this.channelName = channelName;
        this.uri = uri;
        this.results = new ArrayList();
    }

    public CompSign getSign()
    {
        return sign;
    }

    public String getChannelName()
    {
        return channelName;
    }

    public List<FCSAnalyzer.Result> getResults()
    {
        return Collections.unmodifiableList(results);
    }

    public void addResult(FCSAnalyzer.Result result)
    {
        results.add(result);
    }

    public URI getURI()
    {
        return uri;
    }
}
