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
let
  dev = config.hosts.development.enable;

  # Interactive machines (desktop/laptop/workstation/dev) versus untagged,
  # headless boxes (servers, NAS, router, pi). Headless boxes stay slim: they
  # only get `nix` so you can still edit NixOS configs over SSH, without pulling
  # the markup/markdown language servers onto a system nobody edits files on.
  interactive =
    config.hosts.desktop.enable || config.hosts.laptop.enable || config.hosts.workstation.enable || dev;
in
{
  imports = [ ./helix ];

  config = lib.mkMerge [
    {
      development = {
        enable = lib.mkDefault true;
        defaultEditor = lib.mkDefault "helix";

        # Three tiers, slimmest first:
        #   - nix everywhere (every box is a NixOS box you might edit);
        #   - the common system-config formats on interactive machines;
        #   - the rest reserved for development machines.
        languages = {
          # Tier 0 — every system, including headless.
          nix.enable = lib.mkDefault true;

          # Tier 1 — interactive machines: formats used to administer a system.
          json.enable = lib.mkDefault interactive;
          yaml.enable = lib.mkDefault interactive;
          toml.enable = lib.mkDefault interactive;
          markdown.enable = lib.mkDefault interactive;

          # Tier 2 — development machines only.
          python.enable = lib.mkDefault dev;
          xml.enable = lib.mkDefault dev;
          typst.enable = lib.mkDefault dev;
          go.enable = lib.mkDefault dev;
          rust.enable = lib.mkDefault dev;
          bash.enable = lib.mkDefault dev;
          fish.enable = lib.mkDefault dev;
          nu.enable = lib.mkDefault dev;
          latex.enable = lib.mkDefault dev;
          fortran.enable = lib.mkDefault dev;
          matlab.enable = lib.mkDefault dev;
          julia.enable = lib.mkDefault false;
        };

        lsps = {
          codebook.enable = lib.mkDefault dev;
          ltex.enable = lib.mkDefault dev;
          harper.enable = lib.mkDefault false;
          copilot.enable = lib.mkDefault false;
          lsp-ai.enable = lib.mkDefault false;
        };
      };

      programs.helix.enable = lib.mkDefault true;
      programs.helix.package = pkgs.unstable.steelix;
    }
    (lib.mkIf dev {
      home.packages = with pkgs.unstable; [ prek ];
    })
  ];
}
