# Credit: this code is based on https://hub.docker.com/r/thebookpeople/hortonworks-registry
# This has been updated to openjdk 11 and also using the latest version of hortonworks-registry-0.9.1
# This has also be changed to use PostgreSQL

from openjdk:11

RUN adduser hortonworks

RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/* && \
#    groupadd -r hortonworks && useradd --no-log-init -r -g hortonworks hortonworks && \
    mkdir -p /opt/ && \
    wget -O /opt/hortonworks-registry-0.9.1.zip https://github.com/hortonworks/registry/releases/download/0.9.1-rc1/hortonworks-registry-0.9.1.zip && \
    unzip /opt/hortonworks-registry-0.9.1.zip -d /opt && \
    chown -R hortonworks:hortonworks /opt/hortonworks-registry-0.9.1 && \
    rm /opt/hortonworks-registry-0.9.1.zip && \
    ln -s /opt/hortonworks-registry-0.9.1 /opt/hortonworks-registry

WORKDIR /opt/hortonworks-registry

COPY config/registry.yaml.template /opt/hortonworks-registry/conf/registry.yaml.template
COPY entrypoint.sh /opt/hortonworks-registry/entrypoint.sh
COPY wait-for-it.sh /opt/hortonworks-registry/wait-for-it.sh

RUN chmod +x /opt/hortonworks-registry/entrypoint.sh && \
    chmod +x /opt/hortonworks-registry/wait-for-it.sh && \
    chown -R hortonworks:hortonworks /opt/hortonworks-registry-0.9.1


ENV DB_NAME schema_registry
ENV DB_USER postgres
ENV DB_PASSWORD postgres
ENV DB_HOST localhost
ENV DB_PORT 3306

EXPOSE 9090

USER hortonworks

ENTRYPOINT ["./entrypoint.sh"]

CMD ["./bin/registry-server-start.sh","./conf/registry.yaml"]
