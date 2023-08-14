{nixify, ...}: pkgs: languages:
with nixify.lib;
with pkgs.lib; let
  config = readTOML ./config.toml;

  mkInterfaceTestComponent = name: target: lang:
    pkgs.mkTestComponent {
      name = "${lang}-${name}";
      interface = config.${name}.interface;
      runner = languages.${lang}.getRunner name target;
      test = languages.${lang}.getTest name target;
    };

  mapConfigNames = f: mapAttrs f config;

  mkTestCases = target: let
    # ${name} -> ${lang} -> package
    cases = mapConfigNames (
      name: {
        interface,
        languages ? [],
        runner,
      }:
        genAttrs languages (mkInterfaceTestComponent name target)
    );

    # ${name} -> test-case-${name}-${lang}-${target} -> package
    cases' = mapAttrs (name: mapAttrs' (lang: nameValuePair "test-case-${name}-${lang}-${target}")) cases;
  in
    # test-case-${name}-${lang}-${target} -> package
    foldl' mergeAttrs {} (attrValues cases');

  cases-wasm32-unknown-unknown = mkTestCases "wasm32-unknown-unknown";
  cases-wasm32-wasi = mkTestCases "wasm32-wasi";
in {
  packages =
    cases-wasm32-unknown-unknown
    // cases-wasm32-wasi;
}
