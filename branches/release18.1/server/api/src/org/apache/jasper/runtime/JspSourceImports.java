/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.jasper.runtime;

import org.labkey.api.annotations.TomcatVersion;

import java.util.Set;

/**
 * The EL engine needs access to the imports used in the JSP page to configure
 * the ELContext. The imports are available at compile time but the ELContext
 * is created lazily per page. This interface exposes the imports at runtime so
 * that they may be added to the ELContext when it is created.
 */

@TomcatVersion  // Temporary hack that lets JSPs compiled with Tomcat 8 run on Tomcat 7
public interface JspSourceImports {
    Set<String> getPackageImports();
    Set<String> getClassImports();
}
