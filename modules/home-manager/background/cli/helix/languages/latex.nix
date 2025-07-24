# https://www.reddit.com/r/HelixEditor/comments/1iroqa1/latex_configuration/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  ls = config.programs.helix.languages.language-server;
in
{
  options.helix.latex.enable = lib.mkEnableOption "Helix Latex config";

  config = lib.mkIf config.helix.latex.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "latex";
            auto-format = true;
            # scope = "source.julia";
            # injection-regex = "julia";
            # file-types = [ "jl" ];
            # roots = [
            #   "Project.toml"
            #   "Manifest.toml"
            #   "JuliaProject.toml"
            # ];
            # comment-token = "#";
            language-servers = [
              "texlab"
            ]
            ++ lib.optionals (ls ? ltex) [ "ltex" ]
            ++ lib.optionals (ls ? gpt) [ "gpt" ];
            # formatter = {
            #   command = "julia";
            #   args = [
            #     "--startup-file=no"
            #     "--history-file=no"
            #     "--quiet"
            #     "-e"
            #     ''using JuliaFormatter; println(format_text(join(readlines(stdin), '\n')))''
            #   ];
            # };
          }
        ];
        language-server = {
        };
      };

      extraPackages = with pkgs; [ texlab ];
    };
  };
}
