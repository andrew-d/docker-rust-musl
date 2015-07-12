#!/bin/bash

set -e
set -o pipefail
set -x


BUILD_DIR=/build


function install_dependencies() {
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy

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

    mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}
}

function install_musl() {
    echo "** Installing musl"
    cd ${BUILD_DIR}

    if [ -d "/usr/local/musl" ]; then
        return
    fi

    curl -LO http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz
    tar zxvf musl-${MUSL_VERSION}.tar.gz
    cd musl-${MUSL_VERSION}
    ./configure
    make -j4
    make install
}

function build_llvm_components() {
    cd ${BUILD_DIR}

    if [ -f "/usr/local/musl/lib/libunwind.a" ]; then
        return
    fi

    echo "** Fetching sources"
    cd ${BUILD_DIR}               && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
    cd ${BUILD_DIR}/llvm/tools    && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
    cd ${BUILD_DIR}/llvm/projects && svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
    cd ${BUILD_DIR}               && svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
    cd ${BUILD_DIR}               && svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi
    cd ${BUILD_DIR}               && svn co http://llvm.org/svn/llvm-project/libunwind/trunk libunwind

    echo "** Building libcxxabi"

    cd ${BUILD_DIR}/libcxxabi
    mkdir build && cd build
    cmake -DLIBCXXABI_LIBCXX_PATH=${BUILD_DIR}/libcxx -DLLVM_PATH=${BUILD_DIR}/llvm ..
    make

    echo "** Building libunwind"

    cd ${BUILD_DIR}/libunwind
    ln -s ${BUILD_DIR}/libcxxabi/include/__cxxabi_config.h ./include/__cxxabi_config.h
    mkdir build && cd build
    cmake -DLLVM_PATH=${BUILD_DIR}/llvm -DLIBUNWIND_ENABLE_SHARED=OFF ..
    make

    echo "** Copying to output"

    cp ./lib/libunwind.a /usr/local/musl/lib/
}

function build_rust() {
    echo "** Building rust"

    cd ${BUILD_DIR}
    if [ ! -d "${BUILD_DIR}/rust" ]; then
        git clone --depth 1 https://github.com/rust-lang/rust.git
        cd rust

        ./configure                             \
            --target=x86_64-unknown-linux-musl  \
            --musl-root=/usr/local/musl/
    else
        cd rust
    fi

    # These environment variables are set from the Dockerfile and control what
    # we build and whether we install the compiler.
    make ${RUST_BUILD_TARGET}
    if [ "x${RUST_BUILD_INSTALL}" == "xtrue" ]; then
        make install
    fi
}

function install_cargo() {
    echo "** Installing Cargo"

    if [ -f "/usr/local/bin/cargo" ]; then
        return
    fi

    cd ${BUILD_DIR}
    curl -LO https://static.rust-lang.org/cargo-dist/cargo-nightly-x86_64-unknown-linux-gnu.tar.gz
    tar zxf cargo-nightly-x86_64-unknown-linux-gnu.tar.gz
    USER=root ./cargo-nightly-x86_64-unknown-linux-gnu/install.sh
}

function cleanup() {
    if [ "x${RUST_BUILD_CLEAN}" == "xtrue" ]; then
        rm -rf ${BUILD_DIR}
        apt-get clean
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    fi
}

function main() {
    install_dependencies
    install_musl
    build_llvm_components
    build_rust
    install_cargo
    cleanup

    echo "** Done"
}

main
