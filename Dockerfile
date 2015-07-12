FROM debian:jessie
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Set up environment and then just run the build script.
ENV MUSL_VERSION        1.1.10
ENV RUST_BUILD_TARGET   all
ENV RUST_BUILD_INSTALL  true
ENV RUST_BUILD_CLEAN    true

ADD build.sh /build/build.sh
RUN /build/build.sh
