{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
  ];
  # imports = [
  #   inputs.nixvim.homeManagerModules.nixvim
  #   # ./auto.nix
  #   ./options.nix
  #   ./keymaps.nix
  #   ./plugins
  # ];

  # programs.nixvim = {
  #   enable = true;
  #   package = pkgs.unstable.neovim-unwrapped;
  #   # vimAlias = true;
  #   editorconfig.enable = true;
  #   opts.background = "dark";
  #   colorschemes = {
  #     gruvbox = {
  #       enable = true;
  #     };
  #     tokyonight = {
  #       enable = false;
  #       settings.style = "night";
  #     };
  #     catppuccin = {
  #       enable = false;
  #       settings.flavour = "macchiato";
  #     };
  #   };
  #   extraConfigLua = ''
  #     vim.cmd("let g:netrw_liststyle = 3")
  #   '';
  #   clipboard.providers.wl-copy.enable = true;
  # };

  # home.packages = with pkgs; [
  #   unstable.vim-startuptime
  # ];
}
