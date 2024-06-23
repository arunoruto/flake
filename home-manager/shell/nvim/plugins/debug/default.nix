{
  imports = [
    ./ui.nix
    ./python.nix
  ];
  programs.nixvim = {
    plugins.dap = {
      enable = true;
    };
  };
}
