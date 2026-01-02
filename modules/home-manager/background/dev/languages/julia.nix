{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.dev;
in
{
  programs.dev.languages.julia = {
    extensions = [ ".jl" ];
    helix.fileTypes = [ "jl" ];
    autoFormat = true;
    roots = [
      "Project.toml"
      "Manifest.toml"
      "JuliaProject.toml"
    ];
    lspServers = [ "julia-lsp" ];

    helix.languageConfig = {
      scope = "source.julia";
      injection-regex = "julia";
      comment-token = "#";
    };

    formatter = {
      package = pkgs.julia;
      command = lib.getExe pkgs.julia;
      args = [
        "--startup-file=no"
        "--history-file=no"
        "--quiet"
        "-e"
        "using JuliaFormatter; println(format_text(join(readlines(stdin), '\\n')))"
      ];
    };
  };
}
