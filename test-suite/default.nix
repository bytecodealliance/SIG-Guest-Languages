inputs: pkgs: {
  java = import ./java inputs pkgs;
  javascript = import ./javascript inputs pkgs;
  python = import ./python inputs pkgs;
  rust = import ./rust inputs pkgs;
}
