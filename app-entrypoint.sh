#!/bin/bash

set -e

if [ -f /app/tmp/pids/server.pid ]; then rm -rf /app/tmp/pids/server.pid; fi

exec "$@"
