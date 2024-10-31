{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "hlchunk";
        src = builtins.fetchGit {
          url = "https://github.com/shellRaining/hlchunk.nvim";
          ref = "main";
        };
      })
    ];
    extraConfigLua = ''
      require('hlchunk').setup({
        indent = {
          chars = { "│", "¦", "┆", "┊", }, -- more code can be found in https://unicodeplus.com/

          style = {
            "#8B00FF",
          },
        },
        blank = {
          enable = false,
        }
      })
    '';
  };
}
