{nixify, ...}: pkgs:
with pkgs.lib;
with nixify.lib;
with nixify.lib.rust; let
  attrs =
    mkAttrs {
      pname = "test-suite-rust";
      src = ./.;
      rustupToolchain = readTOML ./rust-toolchain.toml;

      doCheck = false; # Testing is performed externally

      targets.aarch64-apple-darwin = false;
      targets.aarch64-unknown-linux-gnu = false;
      targets.aarch64-unknown-linux-musl = false;
      targets.armv7-unknown-linux-musleabihf = false;
      targets.x86_64-apple-darwin = false;
      targets.x86_64-pc-windows-gnu = false;
      targets.x86_64-unknown-linux-gnu = false;
      targets.x86_64-unknown-linux-musl = false;

      buildOverrides = {pkgs, ...}: {
        preBuild ? "",
        postPatch ? "",
        nativeBuildInputs ? [],
        CARGO_BUILD_TARGET ? "",
        CARGO_PROFILE ? "",
        ...
      } @ craneArgs: let
        cargoArgs = concatStrings (
          optional (CARGO_BUILD_TARGET != "") "--target ${CARGO_BUILD_TARGET} " # TODO: Remove once https://github.com/bytecodealliance/cargo-component/issues/106 resolved
          ++ optional (CARGO_PROFILE != "dev") "--release "
        );
      in
        optionalAttrs (craneArgs ? cargoArtifacts) {
          cargoBuildCommand = "cargo component build ${cargoArgs}";

          postPatch =
            postPatch
            + ''
              substituteInPlace "./numbers-runner/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'
              substituteInPlace "./numbers/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'

              substituteInPlace "./trivial-runner/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'
              substituteInPlace "./trivial/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'
            '';

          nativeBuildInputs =
            nativeBuildInputs
            ++ [
              pkgs.cargo-component
            ];
        };
    }
    pkgs;
in
  attrs
  // {
    # TODO: Add support for `cargoClippyCommand`, `cargoDocCommand` and `cargoNextestCommand` to `crane` and re-enable
    checks = filterAttrs (name: _: name != "clippy" && name != "doc" && name != "nextest") attrs.checks;

    packages = let
      mkNumbersTestComponent = pkg: pkgs.mkNumbersTestComponent "rust" "${pkg}/lib/numbers.wasm";
      mkTrivialTestComponent = pkg: pkgs.mkTrivialTestComponent "rust" "${pkg}/lib/trivial.wasm";
    in
      attrs.packages
      // {
        test-suite-rust-numbers-wasm32-unknown-unknown = mkNumbersTestComponent attrs.packages.test-suite-rust-wasm32-unknown-unknown;
        test-suite-rust-numbers-wasm32-wasi = mkNumbersTestComponent attrs.packages.test-suite-rust-wasm32-wasi;

        test-suite-rust-trivial-wasm32-unknown-unknown = mkTrivialTestComponent attrs.packages.test-suite-rust-wasm32-unknown-unknown;
        test-suite-rust-trivial-wasm32-wasi = mkTrivialTestComponent attrs.packages.test-suite-rust-wasm32-wasi;
      };
  }
