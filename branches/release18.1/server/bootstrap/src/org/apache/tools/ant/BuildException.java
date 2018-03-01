/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.apache.tools.ant;

/**
 * LabKey's stub version of ant's BuildException. Tomcat's JspC requires this class; providing it and a few others in our
 * bootstrap jar eliminates the need to distribute and deploy ant.jar into the /tomcat/lib directory.
 *
 * Created by adam on 5/27/2017.
 */
@SuppressWarnings("unused")
public class BuildException extends RuntimeException
{
    public BuildException(String message) {
        super(message);
    }

    public BuildException(Throwable cause) {
        super(cause.toString());
    }
}