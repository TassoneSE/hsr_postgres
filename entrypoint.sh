#!/bin/bash
envsubst < /opt/hortonworks-registry-0.9.1/conf/registry.yaml.template > /opt/hortonworks-registry-0.9.1/conf/registry.yaml
./wait-for-it.sh $DB_HOST:$DB_PORT --timeout=30 --strict -- /opt/hortonworks-registry-0.9.1/bootstrap/bootstrap-storage.sh create
exec "$@"
