#!/bin/env bash
# OS Requirements:
#> sudo apt install -y postgresql-common
#> sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
#> sudo apt install postgresql-16

echo "Starting PostgreSQL server..."
/usr/lib/postgresql/16/bin/postgres -D . --auth-local peer --auth-host scram-sha-256 --no-instructions
