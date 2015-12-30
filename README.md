# docker-rust-musl

This repository contains a `Dockerfile` that builds an image with the
[rust][1] toolchain installed, targeting the [musl][2] libc.  This uses the
[experimental musl support][3] that was recently merged into the compiler.
Since this is experimental, things might not work!  If you have a problem,
please feel free to [file an issue][4].

This image is also an automated build on the Docker hub - you can fetch it by
running: `docker pull andrewd/rust-musl`.

## How To Use

Pass the `--target x86_64-unknown-linux-musl` flag to `cargo build`.  The
build output will be in the `./target/x86_64-unknown-linux-musl/` directory.

Note: you might get errors about being unable to find the `c` library - e.g.
if you're using the `libc` crate.  The [`rustc script`][5] in this repository
can help solve that problem - see the comment at the top of the file.

[1]: https://github.com/rust-lang/rust
[2]: http://www.musl-libc.org/
[3]: https://github.com/rust-lang/rust/pull/24777
[4]: https://github.com/andrew-d/docker-rust-musl/issues/new
[5]: https://github.com/andrew-d/docker-rust-musl/blob/master/rustc
