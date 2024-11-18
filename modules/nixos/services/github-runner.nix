{
  lib,
  pkgs,
  config,
  ...
}:
let
  gh-user = "github";
  workDir = "/srv/yasf";
  cfg = config.services.github-runners.YASF;
in
{
  users = lib.mkIf cfg.enable {
    users.${gh-user} = {
      name = gh-user;
      group = gh-user;
      isSystemUser = true;
      description = "User for running GitHub related things";
    };
    groups.${gh-user} = { };
  };

  services.github-runners.YASF = {
    enable = lib.mkDefault false;
    url = "https://github.com/AGBV/YASF";
    tokenFile =
      if cfg.enable then config.sops.secrets."tokens/yasf-runner".path else ./github-runner.nix;
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

  systemd.tmpfiles.settings.yasf-files = lib.mkIf cfg.enable {
    ${workDir}.d = {
      user = gh-user;
      group = gh-user;
      mode = "0744";
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    "tokens/yasf-runner" = {
      owner = config.users.users.${gh-user}.name;
      inherit (config.users.users.${gh-user}) group;
    };
  };
}
