/*
 * Copyright (c) 2005-2008 LabKey Corporation
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
package org.labkey.api.exp;

/**
 * User: phussey
 * Date: Jun 6, 2005
 */
public class XarFormatException extends ExperimentException
{
    public XarFormatException(String msg)
    {
        super(msg);
    }

    public XarFormatException(Throwable e)
    {
        super(e);
    }

    public XarFormatException(String message, Throwable cause)
    {
        super(message, cause);
    }
}
