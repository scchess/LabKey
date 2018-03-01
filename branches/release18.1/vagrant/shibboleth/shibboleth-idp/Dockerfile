FROM ubuntu

MAINTAINER LabKey Test Team <test@labkey.com>

ENV JRE_HOME /opt/jre1.7.0_79
ENV JAVA_HOME /opt/jre1.7.0_79
ENV JETTY_HOME /opt/jetty
ENV JETTY_BASE /opt/iam-jetty-base
ENV PATH $PATH:$JRE_HOME/bin:/opt/container-scripts

# Update the Ubuntu and install required tools
RUN (apt-get update; \
     apt-get -y -q install wget tar unzip nano netcat; \
     apt-get clean -y)


# Download Java, verify the hash, and install
RUN set -x; \
    java_version=7u79; \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/$java_version-b15/jre-$java_version-linux-x64.tar.gz \
    && echo "fcd884a57920d90fa23240abb403fcf5  jre-$java_version-linux-x64.tar.gz" | md5sum -c - \
    && tar -zxvf jre-$java_version-linux-x64.tar.gz -C /opt \
    && rm jre-$java_version-linux-x64.tar.gz


# Download Jetty, verify the hash, and install, initialize a new base
RUN set -x; \
    jetty_version=9.2.14.v20151106; \
    wget -O jetty.zip "https://eclipse.org/downloads/download.php?file=/jetty/$jetty_version/dist/jetty-distribution-$jetty_version.zip&r=1" \
    && echo "89c038a43d501179ae16d51d60d951ef0ec347cd  jetty.zip" | sha1sum -c - \
    && unzip jetty.zip -d /opt \
    && mv /opt/jetty-distribution-$jetty_version /opt/jetty \
    && rm jetty.zip \
    && cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty \
    && mkdir -p /opt/iam-jetty-base/modules \
    && mkdir -p /opt/iam-jetty-base/lib/ext \
    && cd /opt/iam-jetty-base \
    && touch start.ini \
    && $JRE_HOME/bin/java -jar ../jetty/start.jar --add-to-startd=http,https,deploy,ext,annotations,jstl,logging,setuid \
    && sed -i 's/jetty.port=8080/jetty.port=80/g' /opt/iam-jetty-base/start.d/http.ini \
    && sed -i 's/https.port=8443/https.port=443/g' /opt/iam-jetty-base/start.d/https.ini \
    && sed -i 's/jetty.secure.port=8443/jetty.secure.port=443/g' /opt/iam-jetty-base/start.d/ssl.ini \
    && sed -i 's/<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"\/>/<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"><Set name="showContexts">false<\/Set><\/New>/g' /opt/jetty/etc/jetty.xml

# Download setuid, verify the hash, and place
RUN set -x; \
    wget https://repo1.maven.org/maven2/org/mortbay/jetty/libsetuid/8.1.9.v20130131/libsetuid-8.1.9.v20130131.so \
    && echo "7286c7cb836126a403eb1c2c792bde9ce6018226  libsetuid-8.1.9.v20130131.so" | sha1sum -c - \
    && mv libsetuid-8.1.9.v20130131.so /opt/iam-jetty-base/lib/ext/


# Download Shibboleth IdP, verify the hash, and install
RUN set -x; \
    shibidp_version=3.1.1; \
    wget https://shibboleth.net/downloads/identity-provider/$shibidp_version/shibboleth-identity-provider-$shibidp_version.zip \
    && echo "06a7b0cedd9246c10664fb75c84ea2cc2477d8c2  shibboleth-identity-provider-$shibidp_version.zip" | sha1sum -c - \
    && unzip shibboleth-identity-provider-$shibidp_version.zip -d /opt \
    && cd /opt/shibboleth-identity-provider-$shibidp_version/ \
    && bin/install.sh -Didp.keystore.password=CHANGEME -Didp.sealer.password=CHANGEME -Didp.host.name=localhost.localdomain \
    && cd / \
    && keytool -v -importkeystore -srckeystore /opt/shibboleth-idp/credentials/idp-backchannel.p12 -srcstoretype PKCS12 -destkeystore /opt/shibboleth-idp/credentials/idp-backchannel.jks -deststoretype JKS -srcstorepass CHANGEME -deststorepass CHANGEME \
    && chmod -R +r /opt/shibboleth-idp/ \
    && sed -i 's/ password/CHANGEME/g' /opt/shibboleth-idp/conf/idp.properties \
    && echo "-Didp.home=/opt/shibboleth-idp" >> /opt/iam-jetty-base/start.ini \
    && echo "--exec" >> /opt/iam-jetty-base/start.ini \
    && rm -r /shibboleth-identity-provider-$shibidp_version.zip /opt/shibboleth-identity-provider-$shibidp_version/ 


# Download the library to allow SOAP Endpoints, verify the hash, and place
RUN set -x; \
    wget https://build.shibboleth.net/nexus/content/repositories/releases/net/shibboleth/utilities/jetty9/jetty9-dta-ssl/1.0.0/jetty9-dta-ssl-1.0.0.jar \
    && echo "2f547074b06952b94c35631398f36746820a7697  jetty9-dta-ssl-1.0.0.jar" | sha1sum -c - \
    && mv jetty9-dta-ssl-1.0.0.jar /opt/iam-jetty-base/lib/ext/

ADD iam-jetty-base/ /opt/iam-jetty-base/

RUN useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /opt/jetty \
    && chown -R jetty:jetty /opt/iam-jetty-base \
    && chown -R jetty:jetty /opt/shibboleth-idp/logs


ADD container-scripts/ /opt/container-scripts/
RUN chmod -R +x /opt/container-scripts/

#
# Post install configs to enable docker shibboleth-idp to be used for testing by sp.testship.org test shibboleth-sp and the docker openldap
#

# ensure jetty can write to /opt/shibboleth-idp/logs
RUN chown -R jetty:jetty /opt/shibboleth-idp/logs

# ensure jetty can write to /opt/shibboleth-idp/metadata so that metadata specified by url in metadata-providers.xml can be written there
RUN chmod a+rwx /opt/shibboleth-idp/metadata

# modify /opt/shibboleth/metadata/idp-metadata.xml to specify our entityID and the external ip address for this docker vm since we will using a browser outside the vm to access it
# we copy over this file later
#RUN sed -i 's/entityID="https:\/\/localhost.localdomain\/idp\/shibboleth"/entityID="https:\/\/lktst\/idp\/shibboleth"/g' /opt/shibboleth-idp/metadata/idp-metadata.xml
#RUN sed -i 's/Location="https:\/\/localhost.localdomain/Location="https:\/\/192.168.10.30/g' /opt/shibboleth-idp/metadata/idp-metadata.xml

# modify /opt/shibboleth/conf/idp.properties to specify our entity id
RUN sed -i 's/https:\/\/localhost.localdomain\/idp\/shibboleth/https:\/\/lktst\/idp\/shibboleth/g' /opt/shibboleth-idp/conf/idp.properties

# modify the /opt/shibboleth/conf/ldap.properties to specify our docker openldap server
# we copy over this file later
#RUN sed -i 's/ldap:\/\/localhost:10389/ldap:\/\/192.168.10.30:389/g' /opt/shibboleth-idp/conf/ldap.properties
#RUN sed -i 's/uid=%s,ou=people,dc=example,dc=org/mail=%s,dc=test,dc=labkey,dc=local/g' /opt/shibboleth-idp/conf/ldap.properties
#RUN sed -i 's/ou=people,dc=example,dc=org/dc=test,dc=labkey,dc=local/g' /opt/shibboleth-idp/conf/ldap.properties
#RUN sed -i 's/(uid={user})/(mail={user})/g' /opt/shibboleth-idp/conf/ldap.properties

# modify the /opt/shibboleth/conf/authn/ldap-authn-config.xml to not attempt starttls
RUN sed -i 's/idp.authn.LDAP.useStartTLS:true/idp.authn.LDAP.useStartTLS:false/g' /opt/shibboleth-idp/conf/authn/ldap-authn-config.xml

# modify /opt/shibboleth-idp/conf/metadata-providers.xml to specify how to get the testshib.org sp metadata and where to put it
RUN sed -i '$i<MetadataProvider id="HTTPMetadata" xsi:type="FileBackedHTTPMetadataProvider" backingFile="%{idp.home}\/metadata\/localCopyOfTestShib.xml" metadataURL="http:\/\/www.testshib.org\/metadata\/testshib-providers.xml"\/>' /opt/shibboleth-idp/conf/metadata-providers.xml

# Additional configuration changes for use of a LabKey Server as authorized sp, and send email address in response assertion.
COPY labkeyConfig/conf/ opt/shibboleth-idp/conf/
COPY labkeyConfig/metadata/ opt/shibboleth-idp/metadata/
COPY labkeyConfig/credentials/ opt/shibboleth-idp/credentials/
COPY labkeyConfig/keystore opt/iam-jetty-base/etc/keystore

# Allow --build-arg overrides of default values in the below substitutions
# modify /opt/shibboleth-idp/conf/access-control.xml to allow connections from docker host
ARG gatewayIp=192.168.10.1
RUN sed -i "s/'127.0.0.1\/32', '::1\/128'/'127.0.0.1\/32', '::1\/128', '"${gatewayIp}"\/32', '10.10.10.1\/32'/g" /opt/shibboleth-idp/conf/access-control.xml

# These are the files copied from labkeyConfig; allow overrides of default values used in the vagrant environment
RUN sed -i 's/192.168.10.30/'${gatewayIp}'/g' /opt/shibboleth-idp/metadata/idp-metadata.xml
RUN sed -i 's/192.168.10.30/'${gatewayIp}'/g' /opt/shibboleth-idp/conf/ldap.properties

# On TeamCity, the LabKey Server isn't on port 8080
ARG appPort=8080
ARG contextPath=labkey
#RUN if "${contextPath}" = "" ; then sed -i 's/8080\/labkey/'${appPort}'/g' /opt/shibboleth-idp/metadata/sp-localLabKeyServer.xml; else sed -i 's/8080\/labkey/'${appPort}'\/'${contextPath}'/g' /opt/shibboleth-idp/metadata/sp-localLabKeyServer.xml; fi
RUN sed -i 's/8080\/labkey/'${appPort}'\/'${contextPath}'/g' /opt/shibboleth-idp/metadata/sp-localLabKeyServer.xml

## Opening 443 (browser TLS), 8443 (SOAP/mutual TLS auth)... 80 specifically excluded.
EXPOSE 443 8443

VOLUME ["/external-mount"]

CMD ["run-shibboleth.sh"]
