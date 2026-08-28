# Decky Loader: the Steam Deck plugin loader, which injects a plugin menu into
# Steam's Gaming Mode UI.
#
# The package is not in nixpkgs, so the default is `pkgs.decky-loader` only
# when something has provided it (this flake's overlay does). Everywhere else
# the option resolves to `null` and the module stays inert with a warning
# rather than failing to evaluate — the same reason the rest of this tree
# sticks to plain `pkgs`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.steamos.decky-loader;
  enabled = config.steamos.enable && cfg.enable && cfg.package != null;

  # Decky injects its UI through Steam's CEF debugger, so the flag file that
  # makes Steam open it has to live in the *Steam* user's home — not the
  # unprivileged account plugins run as.
  steamUser = config.steamos.user;
  steamHome = config.users.users.${steamUser}.home;

  # Plugins that need extra Python modules get them through the loader's own
  # interpreter, which the package exposes for exactly this.
  package = cfg.package.overridePythonAttrs (old: {
    dependencies = old.dependencies ++ cfg.extraPythonPackages old.passthru.python.pkgs;
  });
in
{
  options.steamos.decky-loader = {
    enable = lib.mkEnableOption "Decky Loader, the Steam Deck plugin loader";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.decky-loader or null;
      defaultText = lib.literalExpression "pkgs.decky-loader or null";
      description = ''
        The Decky Loader package to run, or `null` when none is available.

        nixpkgs does not package Decky Loader, so this defaults to `null`
        unless an overlay provides `pkgs.decky-loader`. With `null` the module
        does nothing and warns instead of breaking evaluation.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "decky";
      description = ''
        The unprivileged user plugins are run as. The loader itself runs as
        root and drops to this user; see the note in the service definition.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/decky-loader";
      description = "Directory holding installed plugins and their data.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.curl pkgs.unzip ]";
      description = ''
        Extra packages on the loader's `PATH`. Some plugins shell out to
        tools that are not part of a minimal system.
      '';
    };

    extraPythonPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = _: [ ];
      defaultText = lib.literalExpression "pythonPackages: [ ]";
      example = lib.literalExpression "pythonPackages: with pythonPackages; [ hid ]";
      description = ''
        Extra Python packages importable by plugins, as a function of the
        interpreter's package set.
      '';
    };
  };

  config = lib.mkMerge [
    {
      warnings = lib.optional (config.steamos.enable && cfg.enable && cfg.package == null) ''
        steamos.decky-loader.enable is on but no Decky Loader package is
        available, so nothing was configured. nixpkgs does not ship one;
        set steamos.decky-loader.package or provide pkgs.decky-loader
        through an overlay.
      '';
    }

    (lib.mkIf (enabled && cfg.user == "decky") {
      users.users.decky = {
        group = "decky";
        home = cfg.stateDir;
        isSystemUser = true;
      };
      users.groups.decky = { };
    })

    (lib.mkIf enabled {
      systemd.tmpfiles.settings."10-decky-loader" = {
        "${cfg.stateDir}".d = {
          inherit (cfg) user;
          mode = "0755";
        };
        "${cfg.stateDir}/plugins".d = {
          inherit (cfg) user;
          mode = "0755";
        };
      }
      // lib.optionalAttrs (steamUser != null) {
        # Decky reaches into Steam's UI over the CEF debugger that
        # steamwebhelper opens on 127.0.0.1:8080, and Steam only opens it when
        # this file exists at startup. Without it the loader runs, serves on
        # 1337 and is simply never visible in Gaming Mode — which is the whole
        # symptom. Steam has to be restarted after it appears.
        #
        # Note this does mean an unauthenticated debugger into the Steam
        # client, bound to loopback, for as long as Decky is enabled.
        "${steamHome}/.local/share/Steam/.cef-enable-remote-debugging".f = {
          user = steamUser;
          mode = "0644";
        };
      };

      # Upstream requires root: the loader setuids to the unprivileged user to
      # run plugins itself, and running it unprivileged is unsupported and
      # broken. <https://github.com/SteamDeckHomebrew/decky-loader/issues/446>
      systemd.services.decky-loader = {
        description = "Decky Loader";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        # lsof is how the loader finds steamwebhelper's CEF socket, and it
        # drives its own unit through systemctl; neither is guaranteed to be
        # on a service's default PATH.
        path = [
          pkgs.lsof
          config.systemd.package
        ]
        ++ cfg.extraPackages;

        environment = {
          UNPRIVILEGED_USER = cfg.user;
          UNPRIVILEGED_PATH = cfg.stateDir;
          PLUGIN_PATH = "${cfg.stateDir}/plugins";
        };

        serviceConfig = {
          ExecStart = lib.getExe package;
          # Plugins are the service's children; stopping the loader should not
          # take them down mid-write.
          KillMode = "process";
          TimeoutStopSec = 45;
        };
      };
    })
  ];
}
