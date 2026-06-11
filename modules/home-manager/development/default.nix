# Personal development configuration
# Language and editor defaults are set here with lib.mkDefault,
# allowing individual homes to override as needed.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./helix ];

  config = {
    development = {
      enable = lib.mkDefault true;
      defaultEditor = lib.mkDefault "helix";

      languages = {
        nix.enable = lib.mkDefault true;
        python.enable = lib.mkDefault true;
        json.enable = lib.mkDefault true;
        yaml.enable = lib.mkDefault true;
        toml.enable = lib.mkDefault true;
        xml.enable = lib.mkDefault true;
        markdown.enable = lib.mkDefault true;
        typst.enable = lib.mkDefault true;
        go.enable = lib.mkDefault config.hosts.development.enable;
        shells.enable = lib.mkDefault config.hosts.development.enable;
        latex.enable = lib.mkDefault config.hosts.development.enable;
        fortran.enable = lib.mkDefault config.hosts.development.enable;
        matlab.enable = lib.mkDefault config.hosts.development.enable;
        julia.enable = lib.mkDefault false;
      };

      lsps = {
        codebook.enable = lib.mkDefault config.hosts.development.enable;
        ltex.enable = lib.mkDefault config.hosts.development.enable;
        harper.enable = lib.mkDefault false;
        copilot.enable = lib.mkDefault false;
        lsp-ai.enable = lib.mkDefault false;
      };
    };

    programs.helix.enable = lib.mkDefault true;
  };
}
