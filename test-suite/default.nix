inputs: pkgs:
with pkgs.lib; let
  compose = import ./compose inputs pkgs;

  test-suite-compose = compose.packages.test-suite-compose;
  test-suite-wit = pkgs.stdenv.mkDerivation {
    name = "test-suite-wit";
    src = ./test-cases/wit;

    dontUnpack = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      mkdir -p $out
      cp -R $src/*.wit $out
    '';
  };

  mkTestComponent = {
    name,
    interface,
    runner,
    test,
  }:
    pkgs.stdenv.mkDerivation {
      name = "${name}.wasm";

      buildInputs = [
        test-suite-compose
      ];

      dontUnpack = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        ${test-suite-compose}/bin/test-suite-compose '${interface}' '${runner}' '${test}' > $out
      '';
    };

  pkgs' =
    pkgs
    // {
      inherit
        mkTestComponent
        test-suite-compose
        test-suite-wit
        ;
    };

  languages = import ./languages inputs pkgs';
  test-cases = import ./test-cases inputs pkgs' languages;
in {
  inherit
    compose
    languages
    test-cases
    ;
}
