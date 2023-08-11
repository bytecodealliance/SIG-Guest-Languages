inputs: pkgs:
with builtins;
with pkgs.lib;
  mapAttrs (name: _: import ./${name} inputs pkgs) (readDir ./.)
