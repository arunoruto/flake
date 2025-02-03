{
  pkgs,
  config,
  lib,
  ...
}:
let
  ls = config.programs.helix.languages.language-server;
in
{
  options.helix.nix.enable = lib.mkEnableOption "Helix Nix config";

  config = lib.mkIf config.helix.nix.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "nixfmt";
            # formatter.command = "${pkgs.alejandra}/bin/alejandra";
            language-servers =
              [
                "nixd"
                "nil"
              ]
              # ++ lib.optionals (ls ? lsp-ai) [ "lsp-ai" ]
              ++ lib.optionals (ls ? gpt) [ "gpt" ]
              ++ [ ];
          }
        ];
        language-server = {
          nixd = {
            command = "nixd";
            config = config.nixd-config;
          };
        };
      };
      extraPackages = with pkgs; [
        nil
        unstable.nixd
        unstable.nixfmt-rfc-style
        # alejandra
      ];
    };
  };
}
