{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
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
      { mode ="n"; key = "s";  action = ''require("substitute").operator''; lua = true; options.desc = "Substitute with motion"; }
      { mode ="n"; key = "ss"; action = ''require("substitute").line'';     lua = true; options.desc = "Substitute line"; }
      { mode ="n"; key = "S";  action = ''require("substitute").eol'';      lua = true; options.desc = "Substitute to end of line"; }
      { mode ="x"; key = "s";  action = ''require("substitute").visual'';   lua = true; options.desc = "Substitute in visual mode"; }
    ];
  };
}
