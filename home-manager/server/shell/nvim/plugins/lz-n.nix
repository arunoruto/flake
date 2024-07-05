{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs; [
      (vimUtils.buildVimPlugin {
        name = "lz-n";
        src = fetchFromGitHub {
          owner = "nvim-neorocks";
          repo = "lz.n";
          rev = "v1.4.2";
          hash = "sha256-qyCUS+rsUAlHGqCHTkl3dhzPIb/iHP51qjqceDh8Tzw=";
        };
      })
    ];

    extraConfigLua = ''
    '';
  };
}
