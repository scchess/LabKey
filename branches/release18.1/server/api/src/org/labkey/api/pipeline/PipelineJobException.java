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
package org.labkey.api.pipeline;

/*
* User: jeckels
* Date: Jul 28, 2008
*/
public class PipelineJobException extends Exception
{
    private static final String DEFAULT_MESSAGE = "Error during job execution";

    public PipelineJobException()
    {
        super(DEFAULT_MESSAGE);
    }

    public PipelineJobException(String message)
    {
        super(message);
    }

    public PipelineJobException(String message, Throwable cause)
    {
        super(message, cause);
    }

    public PipelineJobException(Throwable cause)
    {
        super(cause.getMessage() == null ? DEFAULT_MESSAGE : cause.getMessage(), cause);
    }
}