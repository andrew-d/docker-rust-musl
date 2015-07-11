FROM debian:jessie
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Install build dependencies and musl
ENV MUSL_VERSION 1.1.10
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy  && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        automake                               \
        build-essential                        \
        cmake                                  \
        curl                                   \
        file                                   \
        git                                    \
        make                                   \
        pkg-config                             \
        python                                 \
        subversion                             \
        texinfo                                \
        wget                                && \
    mkdir -p /build                         && \
    cd /build                               && \
    curl -LO http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz && \
    tar zxvf musl-${MUSL_VERSION}.tar.gz    && \
    cd musl-${MUSL_VERSION}                 && \
    ./configure                             && \
    make -j4                                && \
    make install

RUN echo "Fetching sources"                                                                             && \
    cd /build               && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm                  && \
    cd /build/llvm/tools    && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang                  && \
    cd /build/llvm/projects && svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt    && \
    cd /build               && svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx              && \
    cd /build               && svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi        && \
    cd /build               && svn co http://llvm.org/svn/llvm-project/libunwind/trunk libunwind

RUN echo "Building libcxxabi"                                                                           && \
    cd /build/libcxxabi                                                                                 && \
    mkdir build && cd build                                                                             && \
    cmake -DLIBCXXABI_LIBCXX_PATH=/build/libcxx -DLLVM_PATH=/build/llvm ..                              && \
    make                                                                                                && \
    echo "Building libunwind"                                                                           && \
    cd /build/libunwind                                                                                 && \
    ln -s /build/libcxxabi/include/__cxxabi_config.h ./include/__cxxabi_config.h                        && \
    mkdir build && cd build                                                                             && \
    cmake -DLLVM_PATH=/build/llvm -DLIBUNWIND_ENABLE_SHARED=OFF ..                                      && \
    make                                                                                                && \
    echo "Copying to output"                                                                            && \
    cp ./lib/libunwind.a /usr/local/musl/lib/

# Build rust
RUN echo "Building rust"                                        && \
    git clone --depth 1 https://github.com/rust-lang/rust.git   && \
    cd rust                                                     && \
    ./configure                                                    \
        --target=x86_64-unknown-linux-musl                         \
        --musl-root=/usr/local/musl/                            && \
    make                                                        && \
    make install
