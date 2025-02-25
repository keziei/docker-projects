#!/bin/bash
set -e

# Start PostgreSQL
echo "Starting PostgreSQL..."
exec /usr/bin/postgres -D /var/lib/pgsql/data
