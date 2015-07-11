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
    cd /opt                                 && \
    curl -LO http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz && \
    tar zxvf musl-${MUSL_VERSION}.tar.gz    && \
    cd musl-${MUSL_VERSION}                 && \
    ./configure                             && \
    make -j4                                && \
    make install

RUN echo "Fetching sources"                                                                           && \
    cd /opt               && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm                  && \
    cd /opt/llvm/tools    && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang                  && \
    cd /opt/llvm/projects && svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt    && \
    cd /opt               && svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx              && \
    cd /opt               && svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi        && \
    cd /opt               && svn co http://llvm.org/svn/llvm-project/libunwind/trunk libunwind

RUN echo "Building libcxxabi"                                                                         && \
    cd /opt/libcxxabi                                                                                 && \
    mkdir build && cd build                                                                           && \
    cmake -DLIBCXXABI_LIBCXX_PATH=/opt/libcxx -DLLVM_PATH=/opt/llvm ..                                && \
    make                                                                                              && \
    echo "Building libunwind"                                                                         && \
    cd /opt/libunwind                                                                                 && \
    ln -s /opt/libcxxabi/include/__cxxabi_config.h ./include/__cxxabi_config.h                        && \
    mkdir build && cd build                                                                           && \
    cmake -DLLVM_PATH=/opt/llvm -DLIBUNWIND_ENABLE_SHARED=OFF ..                                      && \
    make                                                                                              && \
    echo "Copying to output"                                                                          && \
    cp ./lib/libunwind.a /usr/local/musl/lib/

# Build rust and install cargo
RUN echo "Building rust"                                            && \
    cd /opt                                                         && \
    git clone --depth 1 https://github.com/rust-lang/rust.git       && \
    cd rust                                                         && \
    ./configure                                                        \
        --target=x86_64-unknown-linux-musl                             \
        --musl-root=/usr/local/musl/                                && \
    make                                                            && \
    make install                                                    && \
    cd /opt                                                         && \
    curl -LO https://static.rust-lang.org/cargo-dist/cargo-nightly-x86_64-unknown-linux-gnu.tar.gz && \
    tar zxf cargo-nightly-x86_64-unknown-linux-gnu.tar.gz           && \
    USER=root ./cargo-nightly-x86_64-unknown-linux-gnu/install.sh   && \
    rm cargo*.tar.gz
