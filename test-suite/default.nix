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

  f = self': let
    mkNumbersTestComponent = lang: test:
      mkTestComponent {
        inherit
          test
          ;
        name = "${lang}-numbers";
        interface = "guest-lang:tests/numbers-api@0.1.0";
        runner = "${self'.rust.packages.test-suite-rust}/lib/numbers_runner.wasm";
      };

    mkTrivialTestComponent = lang: test:
      mkTestComponent {
        inherit
          test
          ;
        name = "${lang}-trivial";
        interface = "guest-lang:tests/trivial-api@0.1.0";
        runner = "${self'.rust.packages.test-suite-rust}/lib/trivial_runner.wasm";
      };

    pkgs' =
      pkgs
      // {
        inherit
          mkNumbersTestComponent
          mkTestComponent
          mkTrivialTestComponent
          test-suite-compose
          test-suite-wit
          ;
      };
  in {
    inherit
      compose
      ;

    java = import ./java inputs pkgs';
    javascript = import ./javascript inputs pkgs';
    python = import ./python inputs pkgs';
    rust = import ./rust inputs pkgs';
  };
in
  fix f
