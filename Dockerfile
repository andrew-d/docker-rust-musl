FROM debian:jessie
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Set up environment
ENV LLVM_VERSION        3.7.0
ENV MUSL_VERSION        1.1.12
ENV RUST_BUILD_TARGET   all
ENV RUST_BUILD_INSTALL  true
ENV RUST_BUILD_CLEAN    true

# Install dependencies (this isn't in the build script because it takes
# forever, and running it here means it can be cached).
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        automake        \
        build-essential \
        cmake           \
        curl            \
        file            \
        git             \
        make            \
        pkg-config      \
        python          \
        subversion      \
        texinfo         \
        wget

ADD build.sh /build/build.sh
RUN /build/build.sh
