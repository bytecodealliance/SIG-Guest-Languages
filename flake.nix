{
  nixConfig.extra-substituters = [
    "https://bytecodealliance.cachix.org"
    "https://nix-community.cachix.org"
    "https://cache.garnix.io"
  ];
  nixConfig.extra-trusted-public-keys = [
    "bytecodealliance.cachix.org-1:0SBgh//n2n0heh0sDFhTm+ZKBRy2sInakzFGfzN531Y="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];

  inputs.fenix.url = github:nix-community/fenix;
  inputs.nixify.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixify.url = github:rvolosatovs/nixify;
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

  outputs = {
    nixify,
    fenix,
    ...
  } @ inputs: let
    mkTestSuite = import ./test-suite inputs;
  in
    with nixify.lib;
      mkFlake {
        overlays = [
          fenix.overlays.default
        ];

        excludePaths = [
          ".gitignore"
          "docs"
          "flake.lock"
          "LICENSE"
          "README.md"
        ];

        withPackages = {pkgs, ...}: let
          test-suite = mkTestSuite pkgs;
        in
          test-suite.compose.packages
          // test-suite.rust.packages;

        withChecks = {pkgs, ...}:
          with pkgs.lib; let
            test-suite = mkTestSuite pkgs;
          in
            mapAttrs' (name: nameValuePair "test-suite-compose-${name}") test-suite.compose.checks
            // mapAttrs' (name: nameValuePair "test-suite-rust-${name}") test-suite.rust.checks;

        withDevShells = {
          devShells,
          pkgs,
          ...
        }:
          with pkgs.lib; let
            test-suite = mkTestSuite pkgs;
          in
            extendDerivations {
              buildInputs = [
                test-suite.compose.packages.test-suite-compose
                test-suite.rust.hostRustToolchain

                pkgs.cargo-component
              ];
            }
            devShells;
      };
}
