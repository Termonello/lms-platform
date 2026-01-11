#!/bin/bash
set -euo pipefail

# Configuration file paths and data directory for Moodle setup
# Copy the template to the config.php

CONFIG_TEMPLATE="/usr/local/etc/moodle-config.php.tpl"
CONFIG_FILE="/var/www/html/config.php"
DATAROOT="${MOODLE_DATAROOT:-/var/www/moodledata}"
WWWROOT="${MOODLE_WWWROOT:-http://localhost}"

# Copy config template if config.php does not exist
if [ ! -f "$CONFIG_FILE" ] && [ -f "$CONFIG_TEMPLATE" ]; then
  cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"
  chown www-data:www-data "$CONFIG_FILE"
fi
# Ensure data directory exists and has correct permissions
mkdir -p "$DATAROOT"
chown -R www-data:www-data "$DATAROOT"

# Check if Moodle is already installed
if ! php /var/www/html/admin/cli/isinstalled.php --quiet >/dev/null 2>&1; then
  if [ -z "${MOODLE_ADMIN_USER:-}" ] || [ -z "${MOODLE_ADMIN_PASS:-}" ] || [ -z "${MOODLE_ADMIN_EMAIL:-}" ]; then
    echo "Missing admin credentials; set MOODLE_ADMIN_USER/MOODLE_ADMIN_PASS/MOODLE_ADMIN_EMAIL." >&2
    exit 1
  fi

  if [ -z "${MOODLE_DBHOST:-}" ] || [ -z "${MOODLE_DBNAME:-}" ] || [ -z "${MOODLE_DBUSER:-}" ]; then
    echo "Missing database settings; set MOODLE_DBHOST/MOODLE_DBNAME/MOODLE_DBUSER." >&2
    exit 1
  fi

if [ ! -f "$DATAROOT/.installed" ]; then
  # install.php ausführen
  touch "$DATAROOT/.installed"
  fi

# Run Moodle installation script
  php /var/www/html/admin/cli/install.php \
    --agree-license \
    --non-interactive \
    --lang=en \
    --wwwroot="$WWWROOT" \
    --dataroot="$DATAROOT" \
    --dbtype="${MOODLE_DBTYPE:-pgsql}" \
    --dbhost="$MOODLE_DBHOST" \
    --dbport="${MOODLE_DBPORT:-5432}" \
    --dbname="$MOODLE_DBNAME" \
    --dbuser="$MOODLE_DBUSER" \
    --dbpass="$MOODLE_DBPASS" \
    --fullname="${MOODLE_SITE_FULLNAME:-Moodle Site}" \
    --shortname="${MOODLE_SITE_SHORTNAME:-Moodle}" \
    --adminuser="$MOODLE_ADMIN_USER" \
    --adminpass="$MOODLE_ADMIN_PASS" \
    --adminemail="$MOODLE_ADMIN_EMAIL"
fi

# Start cron (best effort)
if command -v service >/dev/null 2>&1; then
  service cron start
else
  cron
fi

# Start Apache in the foreground
exec apache2-foreground
