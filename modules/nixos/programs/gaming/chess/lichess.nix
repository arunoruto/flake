{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.lichess-bot;
  format = pkgs.formats.yaml { };
in
{
  options.services.lichess-bot = {
    enable = lib.mkEnableOption "Enable Lichess bot service";
    package = lib.mkPackageOption pkgs "lichess-bot" { };
    settings = lib.mkOption {
      inherit (format) type;
      default = { };
      description = "Settings for the Lichess bot.";
    };
    profiles = lib.mkOption {
      description = "Define individual bot instances.";
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable this bot profile" // {
              default = true;
            };

            # The key to linking Sops
            tokenSecretName = lib.mkOption {
              type = lib.types.str;
              description = "The name of the secret in sops.secrets to use as the token.";
            };

            settings = lib.mkOption {
              inherit (format) type;
              default = { };
              description = "Profile-specific settings (merges with defaults).";
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = "lichess-bot";
              description = "System user to run this bot instance.";
            };
          };
        }

      );
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.lichess-bot = { };
    users.users.lichess-bot = {
      isSystemUser = true;
      group = "lichess-bot";
      description = "Lichess Bot Service User";
    };

    systemd.services = lib.mapAttrs' (
      name: profile:
      lib.nameValuePair "lichess-bot-${name}" (
        lib.mkIf profile.enable {
          description = "Lichess Bot Service - ${name}";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe cfg.package} --config ${
              config.sops.templates."lichess-bot-${name}.yml".path
            }";

            # Security hardening
            User = profile.user;
            Group = "lichess-bot";
            Restart = "always";
            RestartSec = "5s";
            StateDirectory = "lichess-bot-${name}";
            WorkingDirectory = "/var/lib/lichess-bot-${name}";

            # Basic hardening
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
          };

        }
      )
    ) cfg.profiles;

    sops.templates = lib.mapAttrs' (
      name: profile:
      lib.nameValuePair "lichess-bot-${name}.yml" (
        lib.mkIf profile.enable {
          owner = profile.user;
          group = "lichess-bot";
          content =
            let
              mergedSettings = lib.recursiveUpdate cfg.settings profile.settings;
              finalSettings = mergedSettings // {
                token = config.sops.placeholder.${profile.tokenSecretName};
              };
            in
            lib.generators.toYAML { } finalSettings;
        }
      )
    ) cfg.profiles;
  };
}
