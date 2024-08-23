ARG RHEL_VERSION
FROM rockylinux:${RHEL_VERSION}

ARG RHEL_VERSION
ARG PG_VERSION
ARG PG_HINT_PLAN_VERSION


################################################################################
#
# Prerequisite
#
################################################################################

# Install packages for build
RUN dnf update -y
RUN dnf install -y clang gcc git make rpmdevtools

# Install PostgreSQL
RUN if [ "${RHEL_VERSION}" = "8" ]; then \
        dnf install -y --enablerepo=powertools perl-IPC-Run; \
    else \
        dnf install -y --enablerepo=crb perl-IPC-Run; \
    fi
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-${RHEL_VERSION}-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf -qy module disable postgresql
RUN dnf install -y postgresql${PG_VERSION}-server postgresql${PG_VERSION}-devel postgresql${PG_VERSION}-llvmjit postgresql${PG_VERSION}-contrib


################################################################################
#
# Build RPMs
#
################################################################################

# Build by postgres user
USER postgres
WORKDIR /var/lib/pgsql/
ENV PATH /usr/pgsql-${PG_VERSION}/bin:$PATH

RUN rpmdev-setuptree
RUN git clone https://github.com/shinyaaa/pg_hint_plan.git
RUN cd pg_hint_plan && \
    git checkout PG${PG_VERSION} && \
    git archive --format=tar.gz --prefix=pg_hint_plan${PG_VERSION}-${PG_HINT_PLAN_VERSION}/ --output=../rpmbuild/SOURCES/pg_hint_plan${PG_VERSION}-${PG_HINT_PLAN_VERSION}.tar.gz HEAD
RUN cp -a pg_hint_plan/SPECS/pg_hint_plan${PG_VERSION}.spec rpmbuild/SPECS
RUN rpmbuild -bb --define="dist .pg${PG_VERSION}.rhel${RHEL_VERSION}" rpmbuild/SPECS/pg_hint_plan${PG_VERSION}.spec


################################################################################
#
# Run regression tests
#
################################################################################

USER root
RUN cd /var/lib/pgsql/rpmbuild/RPMS/x86_64/ && rpm -ivh *

USER postgres
ENV PGDATA /var/lib/pgsql/${PG_VERSION}/data
RUN initdb --encoding=UTF8 --no-locale
RUN echo "shared_preload_libraries='pg_stat_statements'" >> ${PGDATA}/postgresql.conf
RUN pg_ctl -w start && \
    cd pg_hint_plan && \
    make installcheck
