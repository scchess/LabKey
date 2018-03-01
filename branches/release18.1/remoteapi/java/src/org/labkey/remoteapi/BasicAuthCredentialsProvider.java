/*
 * Copyright (c) 2016 LabKey Corporation
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
package org.labkey.remoteapi;

import org.apache.http.auth.AuthScope;
import org.apache.http.auth.AuthenticationException;
import org.apache.http.auth.Credentials;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.impl.client.BasicCredentialsProvider;

import java.net.URI;
import java.net.URISyntaxException;

/**
 * Created by adam on 4/15/2016.
 */
public class BasicAuthCredentialsProvider implements CredentialsProvider
{
    private final String _email;
    private final String _password;

    public BasicAuthCredentialsProvider(String email, String password)
    {
        _email = email;
        _password = password;
    }

    @Override
    public void configureRequest(String baseUrl, HttpUriRequest request, HttpClientContext httpClientContext) throws AuthenticationException, URISyntaxException
    {
        AuthScope scope = new AuthScope(new URI(baseUrl).getHost(), AuthScope.ANY_PORT, AuthScope.ANY_REALM);
        BasicCredentialsProvider provider = new BasicCredentialsProvider();
        Credentials credentials = new UsernamePasswordCredentials(_email, _password);
        provider.setCredentials(scope, credentials);

        httpClientContext.setCredentialsProvider(provider);
        request.addHeader(new BasicScheme().authenticate(credentials, request, httpClientContext));
    }
}
