#/bin/bash

BUILD_VERSION=0
RHEL_VERSION=("8" "9")
PG_VERSION=("13" "14" "15" "16")
PG_HINT_PLAN_VERSION_13=1.3.10
PG_HINT_PLAN_VERSION_14=1.4.3
PG_HINT_PLAN_VERSION_15=1.5.2
PG_HINT_PLAN_VERSION_16=1.6.1

for RHEL in "${RHEL_VERSION[@]}"; do
  for PG in "${PG_VERSION[@]}"; do
    eval PG_HINT_PLAN_VERSION=\$PG_HINT_PLAN_VERSION_${PG}
    echo "RHEL version: ${RHEL}, PostgreSQL version: ${PG}, pg_hint_plan version: ${PG_HINT_PLAN_VERSION}"
    docker build --build-arg RHEL_VERSION=${RHEL} --build-arg PG_VERSION=${PG} --build-arg PG_HINT_PLAN_VERSION=${PG_HINT_PLAN_VERSION} -t pg_hint_plan:${PG}-${PG_HINT_PLAN_VERSION}-${BUILD_VERSION}-el${RHEL} .
    container_id=$(docker create pg_hint_plan:${PG}-${PG_HINT_PLAN_VERSION}-${BUILD_VERSION}-el${RHEL})
    docker cp $container_id:/var/lib/pgsql/rpmbuild/RPMS ./RPMS-${RHEL}-pg${PG}
    docker rm $container_id
    docker rmi pg_hint_plan:${PG}-${PG_HINT_PLAN_VERSION}-${BUILD_VERSION}-el${RHEL}
  done
done
