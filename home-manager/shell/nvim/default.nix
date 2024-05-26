{
  imports = [
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
