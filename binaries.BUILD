# Distribution of the postgresql binaries, compiled to work on ubuntu linux platform.
# Libraries are supposed to be included via LD_LIBRARY_PATH environment variable.
filegroup(
    name ="distribution",
    srcs = glob([
        "bin/*",
        "lib/**/*",
        "share/**/*",
    ]),
    visibility = ["//visibility:public"],
)
