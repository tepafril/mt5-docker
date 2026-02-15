#!/bin/bash
set -e

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
export PGDATA

# Initialize PostgreSQL cluster on first run
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "[entrypoint] Initializing PostgreSQL..."
  mkdir -p "$PGDATA"
  chown postgres:postgres "$PGDATA"
  su postgres -c "initdb -D $PGDATA"
fi

# Start PostgreSQL in background
echo "[entrypoint] Starting PostgreSQL..."
su postgres -c "pg_ctl -D $PGDATA -l $PGDATA/pg.log -w start"

# Create user and database on first run (when no custom user exists yet)
if [ -n "${POSTGRES_USER:-}" ] && [ -n "${POSTGRES_PASSWORD:-}" ]; then
  if ! su postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='$POSTGRES_USER'\"" | grep -q 1; then
    echo "[entrypoint] Creating user $POSTGRES_USER and database ${POSTGRES_DB:-$POSTGRES_USER}..."
    su postgres -c "psql -v ON_ERROR_STOP=1" <<-EOSQL
      CREATE USER "$POSTGRES_USER" WITH PASSWORD '$POSTGRES_PASSWORD';
      CREATE DATABASE "${POSTGRES_DB:-$POSTGRES_USER}" OWNER "$POSTGRES_USER";
EOSQL
  fi
fi

# Run the original command (MT5/VNC startup)
exec "$@"
