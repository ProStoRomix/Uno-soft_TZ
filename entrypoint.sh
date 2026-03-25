#!/bin/bash
service ssh start
exec /usr/local/bin/docker-entrypoint.sh "$@"