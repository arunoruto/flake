{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-maximizer";
        src = pkgs.fetchFromGitHub {
          owner = "szw";
          repo = "vim-maximizer";
          rev = "2e54952fe91e140a2e69f35f22131219fcd9c5f1";
          hash = "sha256-+VPcMn4NuxLRpY1nXz7APaXlRQVZD3Y7SprB/hvNKww=";
        };
      })
    ];
    keymaps = [
      { mode ="n"; key = "<leader>sm"; action = "<cmd>MaximizerToggle<CR>"; options.desc = "Maximize/minimize a split"; }
    ];
  };
}
