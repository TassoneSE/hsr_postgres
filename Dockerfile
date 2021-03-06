# This has been updated to openjdk 11 and also using the latest version of hortonworks-registry-0.8.1
# This has also be changed to use PostgreSQL

ARG IMAGE_NAME=openjdk
ARG IMAGE_TAG=11
FROM ${IMAGE_NAME}:${IMAGE_TAG}

ARG MAINTAINER="C Tassone <tassone.se@gmail.com>"
LABEL maintainer="${MAINTAINER}"
LABEL site="https://github.com/TassoneSE"

RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r hortonworks && useradd --no-log-init -r -g hortonworks hortonworks && \
    mkdir -p /opt/ && \
    wget -O /opt/hortonworks-registry-0.8.1.zip https://github.com/hortonworks/registry/releases/download/v0.8.1-rc1/hortonworks-registry-0.8.1.zip && \
    unzip /opt/hortonworks-registry-0.8.1.zip -d /opt && \
    chown -R hortonworks:hortonworks /opt/hortonworks-registry-0.8.1 && \
    rm /opt/hortonworks-registry-0.8.1.zip && \
    ln -s /opt/hortonworks-registry-0.8.1 /opt/hortonworks-registry && \
    mkdir -p /opt/hortonworks-registry/logs

WORKDIR /opt/hortonworks-registry

COPY config/registry.yaml.template /opt/hortonworks-registry/conf/registry.yaml.template
COPY entrypoint.sh /opt/hortonworks-registry/entrypoint.sh
COPY wait-for-it.sh /opt/hortonworks-registry/wait-for-it.sh

# Fix the permissions when running in OpenShift
RUN chmod -R a+rwx /opt/hortonworks-registry

RUN chmod +x /opt/hortonworks-registry/entrypoint.sh && \
    chmod +x /opt/hortonworks-registry/wait-for-it.sh && \
    chmod +x /opt/hortonworks-registry/bin/*  && \
    chown -R hortonworks:hortonworks /opt/hortonworks-registry-0.8.1


ENV DB_NAME schema_registry
ENV DB_USER postgres
ENV DB_PASSWORD postgres
ENV DB_HOST localhost
ENV DB_PORT 3306

EXPOSE 9090

#USER hortonworks
USER hortonworks

ENTRYPOINT ["sh", "./entrypoint.sh"]

CMD ["./bin/registry-server-start.sh","./conf/registry.yaml"]



#ARG IMAGE_NAME=openjdk
#ARG IMAGE_TAG=11
#FROM ${IMAGE_NAME}:${IMAGE_TAG}
#
#ARG MAINTAINER="C Tassone <tassone.se@gmail.com>"
#LABEL maintainer="${MAINTAINER}"
#LABEL site="https://github.com/TassoneSE"
#
#
#ARG UID=1000
#ARG GID=1000
#
#ENV HSR_BASE_DIR=/opt/hsr
#ENV HSR_HOME ${HSR_BASE_DIR}/hsr-current
#ENV HSR_TOOLKIT_HOME ${HSR_BASE_DIR}/HSR-toolkit-current
#
#
#ENV HSR_PID_DIR=${HSR_HOME}/run
#ENV HSR_LOG_DIR=${HSR_HOME}/logs
#
##ADD sh/ ${HSR_BASE_DIR}/scripts/
##RUN chmod -R +x ${HSR_BASE_DIR}/scripts/*.sh
#
#
## Setup HSR user and create necessary directories
#RUN groupadd -g ${GID} hsr || groupmod -n hsr `getent group ${GID} | cut -d: -f1` \
#    && useradd --shell /bin/bash -u ${UID} -g ${GID} -m hsr \
#    && mkdir -p ${HSR_BASE_DIR} \
#    && chown -R hsr:hsr ${HSR_BASE_DIR} \
#    && apt-get update \
#    && apt-get install -y jq xmlstarlet procps
#
#USER hsr
#
## Download, validate, and expand Apache NiFi Toolkit binary.
