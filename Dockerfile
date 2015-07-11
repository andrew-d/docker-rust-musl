FROM andrewd/musl-cross
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Install build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy  && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        cmake                                              \
        make                                               \
        python                                             \
        subversion                                      && \
    mkdir -p /build

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
    cp ./lib/libunwind.a /opt/cross/x86_64-linux-musl/x86_64-linux-musl/lib/

# Build rust
RUN echo "Building rust"                                            && \
    git clone --depth 1 https://github.com/rust-lang/rust.git       && \
    cd rust                                                         && \
    ./configure                                                        \
        --target=x86_64-unknown-linux-musl                             \
        --musl-root=/opt/cross/x86_64-linux-musl/x86_64-linux-musl/ && \
    make                                                            && \
    make install
