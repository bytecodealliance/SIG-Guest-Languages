{nixify, ...}: pkgs:
with pkgs.lib;
with nixify.lib;
with nixify.lib.rust;
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
      CARGO_PROFILE ? "release",
      ...
    } @ craneArgs:
      optionalAttrs (craneArgs ? cargoArtifacts) {
        postPatch =
          postPatch
          + ''
            substituteInPlace "./numbers-runner/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'
            substituteInPlace "./numbers/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'

            substituteInPlace "./trivial-runner/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'
            substituteInPlace "./trivial/Cargo.toml" --replace '../../test-cases/wit' '${pkgs.test-suite-wit}'
          '';

        cargoBuildCommand = "cargo component build ${concatStrings (
          optional (CARGO_BUILD_TARGET != "") "--target ${CARGO_BUILD_TARGET} " # TODO: Remove once https://github.com/bytecodealliance/cargo-component/issues/106 resolved
          ++ optional (CARGO_PROFILE != "dev") "--release "
        )}";

        nativeBuildInputs =
          nativeBuildInputs
          ++ [
            pkgs.cargo-component
          ];
      };
  }
  pkgs
