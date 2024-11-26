{
  config,
  lib,
  pkgs,
  ...
}:
let
  ls = config.programs.helix.language-servers;
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
              # ++ lib.optionals (ls ? gpt) [
              #   "gpt"
              # ]
              ++ lib.optionals (ls ? lsp-ai) [
                "lsp-ai"
              ];
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
          ruff = {
            command = "ruff";
            args = [
              "server"
              "--preview"
            ];
          };
          # pylsp.config.pylsp = {
          #   plugins.ruff.enabled = true;
          #   plugins.ruff.formatEnabled = true;
          # };
        };
      };
      extraPackages = with pkgs; [
        python311Packages.debugpy
        pyright
        unstable.ruff
        unstable.isort
      ];
    };
  };
}
