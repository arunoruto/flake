{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}@args:
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
            formatter.command = "nix fmt";
            # formatter.command = "${pkgs.alejandra}/bin/alejandra";
            language-servers =
              [
                "nixd"
                "nil"
              ]
              # ++ lib.optionals (ls ? lsp-ai) [ "lsp-ai" ]
              ++ lib.optionals (ls ? gpt) [ "gpt" ]
              ++ lib.optionals (ls ? copilot) [ "copilot" ]
              ++ [ ];
          }
        ];
        language-server = {
          nixd = {
            command = "nixd";
            config =
              let
                flake-location = config.home.sessionVariables.NH_FLAKE;
              in
              {
                nixpkgs.expr = "import (builtins.getFlake ''${flake-location}'').inputs.nixpkgs { }";
                formatting.command = [ "nix fmt" ];
                options = {
                  nixos.expr =
                    lib.optionalString (args ? nixosConfig)
                      "(builtins.getFlake ''${flake-location}'').nixosConfigurations.${osConfig.networking.hostName}.options";
                  home-manager.expr = "(builtins.getFlake ''${flake-location}'').homeConfigurations.${config.user}.options";
                };
                diagnostics = { };
              };
          };
          nil = {
            command = "nil";
            config.nil = {
              formatting.command = [ "nix fmt" ];
              diagnostics = {
                ignored = [ ];
                excludeFiles = [ ];
              };
              nix = {
                binary = "nix";
                maxMemoryMB = 2560;
                flake = {
                  autoArchive = true;
                  autoEvalInputs = false;
                  nixpkgsInputName = "nixpkgs";
                };
              };
            };
          };
        };
      };
      extraPackages = with pkgs; [
        nil
        unstable.nixd
        # unstable.nixfmt-rfc-style
        # alejandra
      ];
    };
  };
}
