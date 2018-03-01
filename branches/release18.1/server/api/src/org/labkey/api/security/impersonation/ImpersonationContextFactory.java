/*
 * Copyright (c) 2011-2017 LabKey Corporation
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
package org.labkey.api.security.impersonation;

import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;

import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;

/**
 * User: adam
 * Date: 11/9/11
 * Time: 9:58 AM
 */
// We store implementations of this interface in session and construct ImpersonationContexts at each request.  This
// protects us somewhat from user, container, etc. objects getting out-of-date.
public interface ImpersonationContextFactory extends Serializable
{
    ImpersonationContext getImpersonationContext();
    void startImpersonating(ViewContext context);
    void stopImpersonating(HttpServletRequest request);
    User getAdminUser();
}
