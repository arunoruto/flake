{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-startuptime";
        src = pkgs.fetchFromGitHub {
          owner = "dstein64";
          repo = "vim-startuptime";
          rev = "v4.5.0";
          hash = "sha256-hQ7/e7vEJx3j4CQfA6zkQFSe6wrFc9URZ2z47ZulW9A=";
        };
      })
    ];
  };
}
