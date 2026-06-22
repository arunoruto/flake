# Personal development configuration (POLICY).
#
# devix (modules/devix) is pure mechanism: it defines the language/LSP/formatter
# registry and the per-consumer adapters, but enables nothing on its own. This
# file is where the actual choices live — which languages/LSPs are on, and the
# editor defaults — all via lib.mkDefault so individual homes can override.
#
# Consumers attach Stylix-style: each `development.consumers.<name>.enable`
# defaults to `development.autoConfigureEditors && programs.<editor>.enable`.
# So enabling an editor (helix here, zed in foreground/programs, opencode in
# background/cli/ai) is enough for devix to configure it; force a consumer on or
# off explicitly with `development.consumers.<name>.enable`.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./helix ];

  config = lib.mkMerge [
    {
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
          bash.enable = lib.mkDefault config.hosts.development.enable;
          fish.enable = lib.mkDefault config.hosts.development.enable;
          nu.enable = lib.mkDefault config.hosts.development.enable;
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
      programs.helix.package = pkgs.unstable.steelix;
    }
    (lib.mkIf config.hosts.development.enable {
      home.packages = with pkgs.unstable; [ prek ];
    })
  ];
}
