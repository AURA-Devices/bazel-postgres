#!/usr/bin/env bash

# This script builds a Postgres tar.gz file that, once extracted, can run
# standalone on a Linux amd64 system with no pre-installed dependencies (like
# a Bazel remote build execution instance). The Postgres tar.gz file bundles
# shared libraries like OpenSSL and relies on you to set the LD_LIBRARY_PATH
# to <extracted_dir>/lib. See the "Running tests" section below for an example.
#
# Flags
#
# --debug  drop into a bash shell in the build container and test container.
#          To continue after dropping
#          into bash, use 'exit'. You'll need to do it twice.
# --nobuild   skip building and only run tests

set -euo pipefail


postgre_version='17.5'
test_binaries_archive="postgresql-v${postgre_version}.linux-amd64.tar.gz"

script_dir="$(
  cd "$(dirname "$0")"
  pwd -P
)"

debug_cmd='true'
if [[ "$*" == *--debug* ]]; then
  # If run with --debug, drop into a bash shell after building.
  debug_cmd='bash'
fi


if [[ "$*" != *--nobuild* ]]; then
echo "
Building Postgres
=================
"
# Make rm work even if no glob in zsh, https://superuser.com/a/1607656
{ rm -f "$script_dir/test/"*.tar.gz; } 2>/dev/null || true
# Use buildx to always build for Linux amd64.
docker buildx build -t third_party_postgres --platform=linux/amd64 "$script_dir"
docker run -it --rm \
  --platform=linux/amd64 \
  --mount "type=bind,src=$script_dir/test,dst=/work/dist" \
  --workdir='/work/out' \
  third_party_postgres \
  sh -c "$debug_cmd && mv -f /work/${test_binaries_archive} /work/dist/"
else
echo "--nobuild specified, skipping building Postgres"
fi

echo "
Running tests
=============
"
# Use buildx to always build for Linux amd64.
docker buildx build -t third_party_postgres_test -f test.dockerfile --platform=linux/amd64 "$script_dir"
docker run -it --rm \
  --platform=linux/amd64 \
  --env LD_LIBRARY_PATH=/work/lib \
  third_party_postgres_test \
  sh -c "$debug_cmd && /work/bin/initdb /pgdata \
  && /work/bin/pg_ctl -D /pgdata -l logfile start \
  && /work/bin/createdb testdb \
  && /work/bin/dropdb testdb"
