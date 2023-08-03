{nixify, ...}: pkgs:
with pkgs.lib;
with nixify.lib;
with nixify.lib.rust;
  mkAttrs {
    pname = "test-suite-compose";
    src = ./.;

    targets.wasm32-wasi = false;
    targets.wasm32-unknown-unknown = false;
  }
  pkgs
