#!/bin/bash
set -e

# DB connection variables (adjust or override via environment variables)
DB_HOST="${MOODLE_DB_HOST}"
DB_NAME="${MOODLE_DB_NAME}"
DB_USER="${MOODLE_DB_USER}"
DB_PASS="${MOODLE_DB_PASS}"

# Check required variables
for var in DB_HOST DB_NAME DB_USER DB_PASS; do
  if [ -z "${!var}" ]; then
    echo "ERROR: $var is not set!" >&2
    exit 1
  fi
done

MOODLE_ADMIN_USER="${MOODLE_ADMIN_USER:-admin}"
MOODLE_ADMIN_PASS="${MOODLE_ADMIN_PASS:-admin}"
MOODLE_ADMIN_EMAIL="${MOODLE_ADMIN_EMAIL:-admin@example.com}"
MOODLE_SUPPORT_EMAIL="${MOODLE_SUPPORT_EMAIL:-support@example.com}"

# Check if the PostgreSQL database is ready.
if [ "${MOODLE_DB_TYPE}" == "pgsql" ]; then
  echo "Checking database readiness..."
  until PGPASSWORD="$DB_PASS" pg_isready -h "$DB_HOST" -U "$DB_USER" >/dev/null 2>&1; do
    echo "Waiting for database to be ready..."
    sleep 2
  done

  echo "Checking if the '$DB_NAME' database has any tables..."
  TABLE_COUNT=$(PGPASSWORD="$DB_PASS" psql -U "$DB_USER" -h "$DB_HOST" -d "$DB_NAME" -tAc \
    "SELECT count(*)
    FROM pg_catalog.pg_tables
    WHERE schemaname NOT IN ('pg_catalog','information_schema');")

# Check if the MySQL or MariaDB database is ready.
elif [ "${MOODLE_DB_TYPE}" == "mysqli" ] || [ "${MOODLE_DB_TYPE}" == "mariadb" ]; then
  echo "Checking MySQL/MariaDB readiness..."
  until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent; do
    echo "Waiting for database to be ready..."
    sleep 2
  done

  echo "Checking if the '$DB_NAME' database has any tables..."
  TABLE_COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e \
    "SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = '$DB_NAME'
    AND table_name NOT LIKE 'phinxlog';")
else
  echo "ERROR: Unsupported database type: ${MOODLE_DB_TYPE}" >&2
  exit 1
fi

# Trim whitespace just in case
TABLE_COUNT="$(echo "$TABLE_COUNT" | xargs)"

if [ "$TABLE_COUNT" -eq 0 ] 2>/dev/null; then
  echo "Running Moodle CLI database installation..."
  php /var/www/html/admin/cli/install_database.php \
      --fullname="Moodle" \
      --shortname="moodle" \
      --adminuser=$MOODLE_ADMIN_USER \
      --adminpass=$MOODLE_ADMIN_PASS \
      --adminemail=$MOODLE_ADMIN_EMAIL \
      --supportemail=$MOODLE_SUPPORT_EMAIL \
      --agree-license
fi

# Continue with the default startup process
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
