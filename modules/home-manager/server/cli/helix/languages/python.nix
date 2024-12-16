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
                # "pylsp"
                # "basedpyright"
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
          pyright.config.python.analysis.typeCheckingMode = "basic";
          pylsp.config.pylsp.plugins = {
            pylsp_mypy = {
              enabled = true;
              live_mode = true;
            };
            ruff.enabled = true;
          };
          ruff = {
            command = lib.getExe pkgs.unstable.ruff;
            args = [ "server" ];
          };
        };
      };
      extraPackages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            debugpy
            # python-lsp-server
            # python-lsp-ruff
            # pylsp-mypy
            # numpy
            # pydantic
          ]
        ))
        # unstable.basedpyright
        pyright
        (if config.programs.ruff.enable then config.programs.ruff.package else unstable.ruff)
        unstable.isort
      ];
    };
  };
}
