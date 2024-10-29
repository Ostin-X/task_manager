#!/bin/sh
set -e

mix deps.get
mix assets.setup
mix ecto.create
mix ecto.migrate

rm -f tmp/pids/server.pid
mix phx.server
