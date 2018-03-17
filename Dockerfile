FROM sevencode/alpine-openjdk:jdk8

MAINTAINER Seven Code <mail.sevencode@gmail.com>

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 8.2.1.Final
ENV WILDFLY_MODE standalone
ENV JBOSS_HOME /opt/jboss/wildfly
ENV PATH ${PATH}:${JAVA_HOME}/bin
#ENV WILDFLY_DEBUG="-agentlib:jdwp=transport=dt_socket,address=8787,server=y,suspend=n"

RUN apk update && \
    apk add curl tar && \
    rm -rf /var/cache/apk/*

USER root
RUN mkdir -p /opt/jboss && adduser -D -h /opt/jboss jboss

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
WORKDIR /opt
RUN curl http://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz | tar xz && mv ./wildfly-$WILDFLY_VERSION $JBOSS_HOME/ && \
    chown -R jboss:0 ${JBOSS_HOME} && \
    chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# create an wildfly admin user
RUN $JBOSS_HOME/bin/add-user.sh admin admin --silent

## Fix for WFLYCTL0056: Could not rename /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current to ...
RUN rm -rf ${JBOSS_HOME}/standalone/configuration/standalone_xml_history/*

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["sh", "-c", "${JBOSS_HOME}/bin/standalone.sh", "-b", "0.0.0.0"]
