{
  lib,
  config,
  ...
}:
{
  # Deliberately outside the mkIf: where sabnzbd answers is read from another
  # host. aizen's cloudflared ingress builds the public route to shinji out of
  # `config.services.sabnzbd.settings.misc.{port,url_base}`, the same way the
  # entries next to it read services.{sonarr,radarr,lidarr}.settings.server.port
  # — those work only because those services run on their module's default
  # port, and sabnzbd does not. Since this module is imported on every NixOS
  # host, declaring the endpoint here means every host's option tree answers
  # with the values shinji actually runs. Nothing starts: the service itself is
  # still gated on services.sabnzbd.enable, and `settings` is inert without it.
  config = lib.mkMerge [
    {
      services.sabnzbd.settings.misc = {
        # The *arrs reach this over the tailnet, so it cannot sit on loopback.
        host = "0.0.0.0";
        # 8082 is what every download client already points at; the module
        # would otherwise default to 8080.
        port = 8082;
        # The public path, generic on purpose rather than "/sabnzbd" — it is
        # the contract the shared bookmark and aizen's ingress agree on, and
        # it should not have to change if the downloader does.
        #
        # Safe for the *arrs: sabnzbd mounts its whole app twice, at "/" and at
        # url_base (the two cherrypy.tree.mount calls in SABnzbd.py, commented
        # "Make available from both URLs"), so a client pointed at the bare
        # host:port keeps working whatever this says. A client configured with
        # "/sabnzbd" does not — that one has to be emptied or moved here.
        url_base = "/nzb";
      };
    }

    (lib.mkIf config.services.sabnzbd.enable {
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
    })
  ];
}
