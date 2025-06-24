FROM ubuntu:20.04

ARG POSTGRE_VERSION='17.5'
ARG test_binaries_archive="postgresql-v${POSTGRE_VERSION}.linux-amd64.tar.gz"

WORKDIR "/work"

COPY test/"$test_binaries_archive" /work

RUN tar xf "/work/$test_binaries_archive" --directory "/work" \
        && rm "/work/$test_binaries_archive"
