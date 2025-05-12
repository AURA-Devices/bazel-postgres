# Implementation sketch for Bazel-managed Postgres

This is a working solution to build and run Postgres on Bazel for Linux x64.

We compile the Postgres source into a mostly statically-linked Linux binary.
Postgres is quite difficult to compile completely statically, so we bundle all
necessary libs and rely on the user setting LD_LIBRARY_PATH.

We apply a small patch, [allow_root.patch](allow_root.patch) to disable Postgres
binaries from checking for UID 0, the root user. We want to allow root users to
run Postgres because we'll run postgres mostly in Docker containers. We don't
want to have to create a postgres user just to appease Postgres.

To invoke the Postgres binaries, you must set the LD_LIBRARY_PATH so Postgres
will link against the bundled version of glibc.