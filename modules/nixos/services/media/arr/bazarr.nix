{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.bazarr;
in
{
  options.services.bazarr.environment = lib.mkOption {
    type = lib.types.submodule {
      freeformType =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            str
            bool
            path
            package
          ])
        );

      options.DYNACONF_GENERAL__BASE_URL = lib.mkOption {
        type = lib.types.str;
        default = lib.arr.urlBase "bazarr";
        example = "";
        description = ''
          Path bazarr serves itself under, matching the traefik router that
          `lib.arr.arrConfig` generates for it. Set to `""` to serve from the
          root instead.

          This has to stay set rather than being applied once: whenever bazarr
          rewrites its `config.yaml` (a fresh install, or saving any setting in
          the UI) it persists environment-injected keys uppercased
          (`general.BASE_URL`), next to the lowercase key the UI writes, and the
          uppercase copy wins when the two disagree. While the
          variable is set that is harmless -- the environment outranks both, so
          this option is always what decides. Unsetting it entirely is what
          bites: the last value stays behind in `config.yaml` and keeps
          applying. Change the value here, or set `""`; don't remove it.
        '';
      };

      options.DYNACONF_GENERAL__DEBUG = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Log at DEBUG level. The extra lines go to stdout, so read them with
          `journalctl -u bazarr`. Most of what a subtitle sync does (reference
          selection, ffmpeg and ffprobe paths, skipped steps) is only logged at
          this level.

          Declared with a default, rather than left to the freeform set, for the
          same reason as `DYNACONF_GENERAL__BASE_URL`: an injected value can be
          persisted into `config.yaml`, so removing the variable would not
          reliably turn debugging back off. Passing `false` always does.
        '';
      };
    };
    default = { };
    example = {
      DYNACONF_GENERAL__BASE_URL = "/subtitles";
      DYNACONF_SUBSYNC__MAX_OFFSET_SECONDS = "120";
    };
    description = ''
      Environment for the bazarr service.

      bazarr has no configuration file of its own that we would want to own, and
      no CLI flags beyond the config directory and port -- but it reads its
      settings through Dynaconf, which layers environment variables over
      `config.yaml`. Dynaconf is left at its defaults here, so any setting is
      reachable as `DYNACONF_<SECTION>__<KEY>`: the `DYNACONF_` prefix and `__`
      as the nesting separator. `general.base_url` becomes
      `DYNACONF_GENERAL__BASE_URL`.

      The attribute set is freeform, so any variable can be set; the ones
      declared above are the ones this flake depends on and documents. Nix
      booleans are passed as `true`/`false`, which Dynaconf parses back into
      booleans.
    '';
  };

  config = lib.mkIf cfg.enable (
    (lib.arr.arrConfig "bazarr" config pkgs.unstable)
    // {
      users.users.bazarr.extraGroups = lib.optionals (config.users.groups ? "media") [
        config.users.groups.media.name
      ];

      # systemd only takes strings; Dynaconf parses "true"/"false" back to bools.
      systemd.services.bazarr.environment = lib.mapAttrs (
        _: v: if lib.isBool v then lib.boolToString v else v
      ) cfg.environment;
    }
  );
}
