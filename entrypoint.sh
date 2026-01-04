#!/bin/bash
set -euo pipefail

# Start cron (best effort)
if command -v service >/dev/null 2>&1; then
  service cron start
else
  cron
fi

# Start Apache in the foreground
exec apache2-foreground