# local-jennifer
FROM openshift/base-centos7

LABEL maintainer="Khalid Saeed <khalid@jennifersoft.com>"
# ENV BUILDER_VERSION 1.0


ENV WILDFLY_VERSION=12.0.0.Final
ENV MAVEN_VERSION 3.5.3


# Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Builder Image for Wildfly 12.0 with JENNIFER Agent" \
    io.k8s.display-name="local-jennifer" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,jennifer,wildfly" \
    io.openshift.s2i.destination="/opt/s2i/destination"


# Update and OS packages
RUN yum -y update; \
    yum install bc -y; \
    yum install wget -y; \
    yum install tar -y; \
    yum install unzip -y; \
    yum install ca-certificates -y;\
    yum install sudo -y;\
    yum clean all -y


# Install openjdk 1.8
RUN yum install java-1.8.0-openjdk.x86_64* -y && \
  yum clean all -y && \
  rm -rf /var/lib/apt/lists/*

# Wildfly and Maven Setup
WORKDIR /
RUN wget -q -e use_proxy=yes https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz && \
    tar -zxf wildfly-*.tar.gz &&\
    rm -f wildfly-*.tar.gz && \
    mv wildfly-* wildfly

RUN wget -q -e use_proxy=yes https://www.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -zxf apache-maven* -C /usr/local && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /opt/s2i/destination


# Add s2i wildfly customizations
ADD ./contrib/wfmodules/ /wildfly/modules/
ADD ./contrib/wfbin/standalone.conf /wildfly/bin/standalone.conf
ADD ./contrib/wfcfg/standalone.xml /wildfly/standalone/configuration/standalone.xml
ADD ./contrib/settings.xml $HOME/.m2/
COPY ./s2i/bin/ /usr/libexec/s2i

RUN chown -R 1001:0 /wildfly && chown -R 1001:0 $HOME && \
    chmod -R ug+rwx /wildfly && \
    chmod -R g+rw /opt/s2i/destination

# JENNIFER Agent 
COPY jennifer-agent-java-*.zip /jennifer-agent.zip
RUN unzip /jennifer-agent.zip -d / && \
    rm /jennifer-agent.zip

COPY ./contrib/jennifer.conf /agent.java/conf/

RUN chown -R 1001:0 /agent.java && \
    chmod -R ug+rwx /agent.java

# This default user is created in the openshift/base-centos7 image
USER 1001


EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
