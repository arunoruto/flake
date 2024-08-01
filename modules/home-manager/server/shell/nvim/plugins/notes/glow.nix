{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "glow";
        src = pkgs.fetchFromGitHub {
          owner = "ellisonleao";
          repo = "glow.nvim";
          rev = "0.2.0";
          hash = "sha256-TTbS6jDC67MB9iJDyFaLzqAci7cWFdNVFSzrwNLn6fc=";
        };
        # src = builtins.fetchGit {
        #   url = "https://github.com/ellisonleao/glow.nvim";
        #   ref = "main";
        # };
      })
    ];
    extraConfigLua = ''
      require('glow').setup({
        glow_path = "${pkgs.glow}/bin/glow",
        width_ratio = 0.85,
        height_ratio = 0.85,
      })
    '';
  };
}
