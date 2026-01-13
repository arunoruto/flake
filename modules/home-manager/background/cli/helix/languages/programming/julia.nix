# Run this command to set up the language server!
# julia --startup-file=no --project=@helix-lsp -e 'import Pkg; Pkg.add(["LanguageServer", "PackageCompiler"]); Pkg.update();using PackageCompiler; create_sysimage(:LanguageServer, sysimage_path=dirname(Pkg.Types.Context().env.project_file) * "/languageserver.so")'
{
  config,
  lib,
  ...
}:
let
  ls = config.programs.helix.languages.language-server;
in
{
  options.helix.julia.enable = lib.mkEnableOption "Helix Julia config";

  config = lib.mkIf config.helix.julia.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "julia";
            auto-format = true;
            scope = "source.julia";
            injection-regex = "julia";
            file-types = [ "jl" ];
            roots = [
              "Project.toml"
              "Manifest.toml"
              "JuliaProject.toml"
            ];
            comment-token = "#";
            language-servers = [
              "julia-lsp"
            ]
            ++ lib.optionals (ls ? gpt) [
              "gpt"
            ];
            formatter = {
              command = "julia";
              args = [
                "--startup-file=no"
                "--history-file=no"
                "--quiet"
                "-e"
                ''using JuliaFormatter; println(format_text(join(readlines(stdin), '\n')))''
              ];
            };
          }
        ];
        language-server = {
          julia-lsp = {
            command = "julia";
            args = [
              "--startup-file=no"
              "--history-file=no"
              "--thread=auto"
              "-e"
              "using LanguageServer; runserver();"
            ];
            # command = "julia";
            # args = [
            #   "--project=@helix-lsp"
            #   "--startup-file=no"
            #   "--history-file=no"
            #   "--quiet"
            #   "-J${config.home.homeDirectory}/.julia/environments/helix-lsp/languageserver.so"
            #   "--sysimage-native-code=yes"
            #   "-e"
            #   ''
            #     import Pkg
            #     project_path = let
            #         dirname(something(
            #             Base.load_path_expand((
            #                 p = get(ENV, "JULIA_PROJECT", nothing);
            #                 isnothing(p) ? nothing : isempty(p) ? nothing : p
            #             )),
            #             Base.current_project(pwd()),
            #             Pkg.Types.Context().env.project_file,
            #             Base.active_project(),
            #         ))
            #         end
            #     ls_install_path = joinpath(get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")), "environments", "nvim-lspconfig");
            #     pushfirst!(LOAD_PATH, ls_install_path);
            #     using LanguageServer;
            #     popfirst!(LOAD_PATH);
            #     depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
            #     symbol_server_path = joinpath(homedir(), ".cache", "helix", "julia_lsp_symbol_server")
            #     mkpath(symbol_server_path)
            #     server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path, nothing, symbol_server_path, true)
            #     server.runlinter = true
            #     run(server)
            #   ''
            # ];
          };
        };
      };
    };
  };
}
