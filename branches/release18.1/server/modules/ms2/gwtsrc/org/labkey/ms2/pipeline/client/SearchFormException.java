/*
 * Copyright (c) 2008 LabKey Corporation
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

package org.labkey.ms2.pipeline.client;

/**
 * User: billnelson@uky.edu
 * Date: Apr 21, 2008
 */

/**
 * <code>SearchFormException</code>
 */
public class SearchFormException extends Exception
{
    public SearchFormException()
    {
    }

    public SearchFormException(String s)
    {
        super(s);
    }

    public SearchFormException(String s, Throwable throwable)
    {
        super(s, throwable);
    }

    public SearchFormException(Throwable throwable)
    {
        super(throwable);
    }
}
