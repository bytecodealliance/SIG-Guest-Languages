{
  inputs.fenix.url = github:nix-community/fenix;
  inputs.nixify.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixify.url = github:rvolosatovs/nixify;
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

  outputs = {
    nixify,
    fenix,
    ...
  } @ inputs: let
    test-suite-overlay = final: prev: {
      test-suite-wit = prev.stdenv.mkDerivation {
        name = "test-suite-wit";
        src = ./test-suite/test-cases/wit;

        dontUnpack = true;
        dontBuild = true;

        installPhase = ''
          mkdir -p $out
          cp -R $src/*.wit $out
        '';
      };
    };
  in
    with nixify.lib;
      mkFlake {
        overlays = [
          fenix.overlays.default
          test-suite-overlay
        ];

        excludePaths = [
          ".gitignore"
          "docs"
          "flake.lock"
          "LICENSE"
          "README.md"
        ];

        withPackages = {pkgs, ...}: let
          test-suite = import ./test-suite inputs pkgs;
        in
          test-suite.rust.packages;

        withChecks = {pkgs, ...}: let
          test-suite = import ./test-suite inputs pkgs;
        in
          test-suite.rust.checks;
      };
}
