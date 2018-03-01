/*
 * Copyright (c) 2011 LabKey Corporation
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

package org.labkey.study.importer;

/*
* User: adam
* Date: Mar 3, 2011
* Time: 12:51:40 PM
*/
public class VisitMapParseException extends Exception
{
    public VisitMapParseException(String message)
    {
        super(message);
    }

    public VisitMapParseException(String message, Throwable cause)
    {
        super(message, cause);
    }
}
