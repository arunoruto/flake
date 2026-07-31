# Verbatim copy of home-manager's modules/programs/herdr.nix as of
# e8827fbbb12015a8dd9f66285aec79d655bcb9f6. The module landed on master after
# the release-26.05 branch-off, so it is missing from the pinned input.
#
# Do not edit — keeping it byte-identical means dropping this file at 26.11 is a
# no-op. Local additions belong in ./module.nix, which deliberately declares no
# option that this file declares.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;

  cfg = config.programs.herdr;

  tomlFormat = pkgs.formats.toml { };
in
{
  meta.maintainers = [ lib.maintainers.amadejkastelic ];

  options.programs.herdr = {
    enable = lib.mkEnableOption "Herdr";

    package = lib.mkPackageOption pkgs "herdr" { nullable = true; };

    settings = mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = {
        onboarding = false;
        terminal = {
          default_shell = "nu";
          shell_mode = "auto";
          new_cwd = "follow";
        };
        theme = {
          name = "catppuccin";
          auto_switch = true;
          light_name = "catppuccin-latte";
          dark_name = "catppuccin";
        };
        ui = {
          sidebar_width = 32;
          agent_panel_sort = "priority";
          toast.delivery = "herdr";
          sound.enabled = true;
        };
        keys.prefix = "ctrl+b";
        keys.command = [
          {
            key = "prefix+l";
            type = "plugin_action";
            command = "example.layout.apply";
            description = "apply layout";
          }
        ];
      };
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/herdr/config.toml`.
        See <https://herdr.dev/docs/configuration/> for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."herdr/config.toml" = mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "herdr-config.toml" cfg.settings;
      onChange =
        let
          binPath = if cfg.package == null then "herdr" else "${lib.getExe cfg.package}";
        in
        "${binPath} server reload-config || true";
    };
  };
}
