# Rust

Rust can be componentized using `cargo component`.

The metadata for wit file and world name is placed in `Cargo.toml`.

The general form of the command to do so is
```sh
cargo component build --target wasm32-unknown-unknown
```

By default, `cargo component` creates the output as `target/wasm32-unknown-unknown/debug/<crate>.wasm`
