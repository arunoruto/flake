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
  options.helix.python.enable = lib.mkEnableOption "Helix Python config";

  config = lib.mkIf config.helix.python.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "python";
            auto-format = true;
            language-servers =
              [
                "pyright"
                "ruff"
              ]
              ++ lib.optionals (ls ? gpt) [
                "gpt"
              ];
            # ++ lib.optionals (ls ? lsp-ai) [
            #   "lsp-ai"
            # ];
            formatter = {
              command = "bash";
              args = [
                "-c"
                "isort - | ruff format -"
              ];
              # command = "ruff";
              # args = ["format" "--line-length" "88" "--quiet" "-"];
            };
            roots = [
              "setup.py"
              "setup.cfg"
              "pyproject.toml"
              "pyrightconfig.json"
              "Poetry.lock"
            ];
            debugger = {
              name = "debugpy";
              command = "python";
              args = [
                "-m"
                "debugpy.adapter"
              ];
              transport = "stdio";
              templates = [
                {
                  name = "source";
                  request = "launch";
                  completion = [
                    {
                      name = "entrypoint";
                      completion = "filename";
                      default = ".";
                    }
                  ];
                  args = {
                    mode = "debug";
                    program = "{0}";
                  };
                }
              ];
            };
          }
        ];
        language-server = {
          pyright = {
            command = lib.getExe pkgs.unstable.basedpyright;
            config.python.analysis.typeCheckingMode = "basic";
          };
          ruff = {
            command = lib.getExe pkgs.unstable.ruff;
            args = [
              "server"
              # "--preview"
            ];
          };
        };
      };
      extraPackages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            debugpy
          ]
        ))
        pyright
        unstable.ruff
        unstable.isort
      ];
    };
  };
}
