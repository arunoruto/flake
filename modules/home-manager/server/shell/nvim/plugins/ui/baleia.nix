{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "baleia";
        src = builtins.fetchGit {
          url = "https://github.com/m00qek/baleia.nvim";
          ref = "main";
        };
      })
    ];
  };
}
