# Personal development configuration (POLICY).
#
# devix (modules/devix) is pure mechanism: it defines the language/LSP/formatter
# registry and the per-consumer adapters, but enables nothing on its own. This
# file is where the actual choices live — which languages/LSPs are on, and the
# editor defaults — all via lib.mkDefault so individual homes can override.
#
# Consumers attach Stylix-style: each `devix.consumers.<name>.enable`
# defaults to `devix.autoEnable && programs.<editor>.enable`.
# So enabling an editor (helix here, zed in foreground/programs, opencode in
# background/cli/ai) is enough for devix to configure it; force a consumer on or
# off explicitly with `devix.consumers.<name>.enable`.
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
      devix = {
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
          xml.enable = lib.mkDefault false;
          typst.enable = lib.mkDefault dev;
          go.enable = lib.mkDefault dev;
          rust.enable = lib.mkDefault dev;
          bash.enable = lib.mkDefault dev;
          fish.enable = lib.mkDefault dev;
          nu.enable = lib.mkDefault false;
          latex.enable = lib.mkDefault dev;
          fortran.enable = lib.mkDefault false;
          matlab.enable = lib.mkDefault false;
          julia.enable = lib.mkDefault false;
        };

        # Addons contribute servers to the languages above rather than being
        # languages themselves. `grammar` attaches ltex + codebook to the prose
        # formats (markdown, latex, typst); see modules/devix/addons/.
        addons = {
          grammar.enable = lib.mkDefault dev;
          ai.enable = lib.mkDefault false;
        };

        # Which build of a server to use is this flake's choice, not devix's:
        # the data files stay on plain nixpkgs so the exported modules work
        # without our overlays. `command` follows `package` automatically.
        lsps.nixd.package = pkgs.unstable.nixd;
        formatters.nixfmt.package = pkgs.unstable.nixfmt;
      };

      programs.helix.enable = lib.mkDefault true;
      programs.helix.package = pkgs.unstable.helix;
    }
    (lib.mkIf config.devix.addons.ai.enable {
      devix.lsps.copilot.package = pkgs.unstable.copilot-language-server;
    })
    (lib.mkIf dev {
      home.packages = with pkgs.unstable; [ prek ];
    })
  ];
}
