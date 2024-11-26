{
  lib,
  pkgs,
  config,
  ...
}:
let
  gh-user = "github";
  workDir = "/srv/yasf";
in
{
  options.runners.YASF.enable = lib.mkEnableOption "Configure YASF runner with the correct user";

  config = lib.mkIf config.runners.YASF.enable {
    users = {
      users.${gh-user} = {
        name = gh-user;
        group = gh-user;
        isSystemUser = true;
        description = "User for running GitHub related things";
      };
      groups.${gh-user} = { };
    };

    services.github-runners.YASF = {
      enable = lib.mkDefault true;
      url = "https://github.com/AGBV/YASF";
      tokenFile = config.sops.secrets."tokens/yasf-runner".path;
      # if cfg.enable then config.sops.secrets."tokens/yasf-runner".path else ./github-runner.nix;
      name = config.networking.hostName;
      replace = true;
      extraLabels = [
        "gpu"
        "nixos"
      ];
      user = gh-user;
      inherit workDir;
      extraPackages = with pkgs; [
        gawk
        gcc
      ];
    };

    systemd.tmpfiles.settings.yasf-files = {
      ${workDir}.d = {
        user = gh-user;
        group = gh-user;
        mode = "0744";
      };
    };

    sops.secrets = {
      "tokens/yasf-runner" = {
        owner = config.users.users.${gh-user}.name;
        inherit (config.users.users.${gh-user}) group;
      };
    };
  };
}
