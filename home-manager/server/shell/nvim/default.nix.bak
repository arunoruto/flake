let
  sysconfig =
    if builtins.pathExists "/etc/nixos/configuration.nix"
    then (import <nixpkgs/nixos> {}).config
    else "other";
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref =
      if (sysconfig == "other")
      then "main"
      else "nixos-${sysconfig.system.stateVersion}";
  });
in {
  imports = [
    nixvim.homeManagerModules.nixvim
    ./auto.nix
    ./options.nix
    ./keymaps.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    editorconfig.enable = true;
    colorschemes.catppuccin = {
      enable = true;
      flavour = "macchiato";
    };
    extraConfigLua = ''
      vim.cmd("let g:netrw_liststyle = 3")
    '';
    clipboard.providers.wl-copy.enable = true;
  };
}
