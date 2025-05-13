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
  options.helix.go.enable = lib.mkEnableOption "Helix Go config";

  config = lib.mkIf config.helix.go.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "go";
            # scope = "source.f90";
            # file-types = [ "f90" ];
            # comment-token = "!";
            language-servers = [
              "gopls"
              "golangci-lint-langserver"
            ] ++ lib.optionals (ls ? codebook) [ "codebook" ];
            auto-format = true;
            formatter = {
              command = "gofmt";
              args = [ ];
            };
            indent = {
              tab-width = 4;
              unit = " ";
            };
          }
        ];
        language-server = {
          golangci-lint-langserver = {
            command = "golangci-lint-langserver";
            # args = [ "--stdio" ];
          };
        };
      };
      extraPackages = with pkgs; [
        delve
        go
        golangci-lint
        golangci-lint-langserver
        gopls
      ];
    };
  };
}
