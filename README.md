# docker-rust-musl

This repository contains a `Dockerfile` that builds an image with the
[rust][1] toolchain installed, targeting the [musl][2] libc.  This uses the
[experimental musl support][3] that was recently merged into the compiler.
Since this is experimental, things might not work!  If you have a problem,
please feel free to [file an issue][4].

This image is also on the Docker hub - you can fetch it by running:
`docker pull andrewd/rust-musl-norm`.  Currently, I'm building the image on
my computer - I'm hoping to get an automated build working soon.

## How To Use

Pass the `--target x86_64-unknown-linux-musl` flag to `cargo build`.  The
build output will be in the `./target/x86_64-unknown-linux-musl/` directory.

[1]: https://github.com/rust-lang/rust
[2]: http://www.musl-libc.org/
[3]: https://github.com/rust-lang/rust/pull/24777
[4]: https://github.com/andrew-d/docker-rust-musl/issues/new
