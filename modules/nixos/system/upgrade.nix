# Every NixOS host upgrades itself from GitHub: CI bumps flake.lock in a PR,
# builds every host and merges it before the hosts wake up. See
# docs/auto-upgrade.md. Opt a host out with `system.autoUpgrade.enable = false;`.
{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.system.autoUpgrade;
  host = config.networking.hostName;
  # Topic URL (https://ntfy.sh/<secret topic>) that skips and failures go to.
  ntfyCredential = "ntfy:${config.sops.secrets."tokens/ntfy/upgrade".path}";

  guard = pkgs.writeShellApplication {
    name = "nixos-upgrade-guard";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
    ];
    runtimeEnv = {
      REPO = cfg.repo;
      BRANCH = cfg.branch;
      HOST = host;
    };
    text = builtins.readFile ./upgrade-guard.sh;
  };
in
{
  options.system.autoUpgrade = {
    repo = lib.mkOption {
      type = lib.types.str;
      default = "arunoruto/flake";
      description = "GitHub `owner/name` the hosts upgrade from.";
    };
    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Branch the hosts upgrade from.";
    };
  };

  config = lib.mkMerge [
    {
      # The commit a system was built from: `nixos-version --configuration-revision`.
      # A dirty tree gives `<rev>-dirty`, which the upgrade guard refuses to replace.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.autoUpgrade.enable = lib.mkDefault true;
    }
    (lib.mkIf cfg.enable {
      system.autoUpgrade = {
        # Follow the branch (with its committed flake.lock, validated by CI)
        # instead of a frozen store snapshot of the source. Referencing
        # inputs.self.outPath here would also embed the whole flake source in
        # the system closure. No --update-input: CI owns the lock file, and the
        # module already adds --refresh for flakes.
        flake = "github:${cfg.repo}/${cfg.branch}#${config.networking.hostName}";
        flags = [ "--print-build-logs" ];
        # Local time. CI starts at 01:17 UTC, so its merge lands before this
        # in both CET and CEST.
        dates = "05:00";
        randomizedDelaySec = "30min";
        persistent = true;
      };

      sops.secrets."tokens/ntfy/upgrade" = { };

      # The upstream unit is already after/wants network-online.target.
      systemd.services.nixos-upgrade = {
        unitConfig.OnFailure = [ "nixos-upgrade-failed.service" ];
        serviceConfig = {
          ExecCondition = lib.getExe guard;
          LoadCredential = [ ntfyCredential ];
        };
      };

      systemd.services.nixos-upgrade-failed = {
        description = "Report a failed nixos-upgrade";
        path = [ pkgs.curl ];
        serviceConfig = {
          Type = "oneshot";
          LoadCredential = [ ntfyCredential ];
        };
        script = ''
          curl -fsS --max-time 20 -H "Title: nixos-upgrade failed on ${host}" -H "Tags: rotating_light" \
            -d "See: journalctl -u nixos-upgrade -b" "$(<"$CREDENTIALS_DIRECTORY/ntfy")"
        '';
      };
    })
  ];
}
