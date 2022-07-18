#!/bin/bash

USER="${HEALTHCHECK_USER:-postgres}"
DATABASE="${HEALTHCHECK_DATABASE:-postgres}"
HOST="${HEALTHCHECK_HOST:-127.0.0.1}"


result="$(psql \
    --host "${HOST}" \
    --username "${USER}" \
    --dbname "${DATABASE}" \
    --quiet \
    --tuples-only \
    --no-align \
    --command "SELECT 1")"

if [ "${?}" = "0" ] && [ "${result}" = "1" ]; then
    exit 0
fi

exit 1
