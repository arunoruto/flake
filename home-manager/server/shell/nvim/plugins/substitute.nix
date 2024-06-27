{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "substitute";
        src = pkgs.fetchFromGitHub {
          owner = "gbprod";
          repo = "substitute.nvim";
          rev = "v2.0.0";
          sha256 = "sha256-gR2WaBnqTSeBxMuUTjii+BOI0T8+C+poAofk17/Jxkk=";
        };
      })
    ];
    keymaps = [
      {
        mode = "n";
        key = "s";
        action.__raw = ''require("substitute").operator'';
        options.desc = "Substitute with motion";
      }
      {
        mode = "n";
        key = "ss";
        action.__raw = ''require("substitute").line'';
        options.desc = "Substitute line";
      }
      {
        mode = "n";
        key = "S";
        action.__raw = ''require("substitute").eol'';
        options.desc = "Substitute to end of line";
      }
      {
        mode = "x";
        key = "s";
        action.__raw = ''require("substitute").visual'';
        options.desc = "Substitute in visual mode";
      }
    ];
  };
}
