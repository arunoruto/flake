{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.sabnzbd.enable {
    services.sabnzbd = {
      # null selects the module's declarative path: the unit's preStart merges
      # the live ini, then what `settings` generates, then `secretFiles`, with
      # later winning. See the settings block in ../bosflix/sabnzbd.nix.
      configFile = lib.mkForce null;

      # true means the ini stays writable (0600) and the *live* file joins that
      # merge, so the many keys we do not declare survive. Pinned rather than
      # left to default, because the default is derived from stateVersion and
      # flips to false at 26.05 — at which point the live file drops out of the
      # merge and Nix becomes the only source. Since api_key, nzb_key and the
      # usenet credentials are *not* declared, that flip would silently drop
      # them and break every *arr pointed at this host. Moving those into sops
      # via `secretValues` is the prerequisite for setting this false.
      allowConfigWrite = true;
    };

    systemd.services.sabnzbd.serviceConfig.UMask = "0002";

    users.users.sabnzbd.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
