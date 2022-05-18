FROM postgres:14.2 as builder

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        postgresql-14-postgis-3 \
        postgresql-14-pgaudit \
        postgresql-server-dev-14 gcc libgssapi-krb5-2 libkrb5-dev libsasl2-modules-gssapi-mit libz-dev build-essential && \
    rm -rf /var/lib/apt/lists/*


COPY . /pgauditlogtofile/
RUN cd /pgauditlogtofile && make install USE_PGXS=1

FROM postgres:14.2 
ENV HEALTHCHECK_USER postgres
ENV HEALTHCHECK_HOST 127.0.0.1
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        postgresql-14-postgis-3 \
        postgresql-14-pgaudit
COPY --from=builder /usr/lib/postgresql/14/lib/pgauditlogtofile.so /usr/lib/postgresql/14/lib/pgauditlogtofile.so
COPY --from=builder /usr/lib/postgresql/14/lib/bitcode/pgauditlogtofile.index.bc /usr/lib/postgresql/14/lib/bitcode/pgauditlogtofile.index.bc
COPY --from=builder /usr/lib/postgresql/14/lib/bitcode/pgauditlogtofile/ /usr/lib/postgresql/14/lib/bitcode/pgauditlogtofile/
COPY --from=builder /usr/share/postgresql/14/extension/pgauditlogtofile.control /usr/share/postgresql/14/extension/pgauditlogtofile.control
COPY --from=builder /usr/share/postgresql/14/extension/pgauditlogtofile--1.0.sql /usr/share/postgresql/14/extension/pgauditlogtofile--1.0.sql
COPY --from=builder /usr/share/postgresql/14/extension/pgauditlogtofile--1.0--1.2.sql /usr/share/postgresql/14/extension/pgauditlogtofile--1.0--1.2.sql
COPY --from=builder /usr/share/postgresql/14/extension/pgauditlogtofile--1.2--1.3.sql /usr/share/postgresql/14/extension/pgauditlogtofile--1.2--1.3.sql
COPY --from=builder /usr/share/postgresql/14/extension/pgauditlogtofile--1.3--1.4.sql /usr/share/postgresql/14/extension/pgauditlogtofile--1.3--1.4.sql
COPY --from=builder /usr/share/postgresql/14/extension/pgauditlogtofile--1.4--1.5.sql /usr/share/postgresql/14/extension/pgauditlogtofile--1.4--1.5.sql
COPY healthcheck.sh /usr/local/bin
COPY init-logging-extension.sql /docker-entrypoint-initdb.d/

HEALTHCHECK --interval=10s --timeout=30s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh
