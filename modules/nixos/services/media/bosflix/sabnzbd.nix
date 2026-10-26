{
  config,
  lib,
  ...
}:
let
  cfg = config.services.bosflix;
  sabnzbdCfg = config.services.sabnzbd;
in
{
  config = lib.mkIf cfg.enable {
    # host/port/inet_exposure used to be appended to the unit's ExecStart with
    # a mkForce, overriding on the command line what the module already
    # generates into sabnzbd.ini from `settings` — the same values declared
    # twice, in conflict, with the CLI quietly winning. Since
    # ../downloaders/sabnzbd.nix forces `configFile = null`, the declarative
    # path is already active, so all of this belongs in `settings`.
    #
    # Split across two files: host, port and url_base live in
    # ../downloaders/sabnzbd.nix because aizen reads them to build the public
    # route, and anything bosflix-shaped — the paths, the categories named
    # after services.bosflix.syncedFolders — lives here.
    #
    # The ini is merged at service start from, in order: the live
    # /var/lib/sabnzbd/sabnzbd.ini, then what is generated from here, then
    # `secretFiles` — later wins. So everything below is authoritative and the
    # ~280 keys *not* declared (notification back-ends, logging, sorting) go on
    # living in the ini. That split holds only while `allowConfigWrite` is
    # true; flipping it to false makes this the only source, which first
    # requires api_key, nzb_key and the server credentials to move into sops
    # via `secretValues`.
    #
    # Where to look up keys, most to least authoritative:
    #   ${config.services.sabnzbd.package}/sabnzbd/cfg.py — every key, with
    #     its section and type
    #   https://sabnzbd.org/wiki/configuration/5.1/configure
    #   nixos/modules/services/networking/sabnzbd/default.nix, for the subset
    #     the module types explicitly (misc.*, servers.*)
    #
    # Do not pass Nix lists here: the module's type accepts `listOf`, but the
    # ini generator aborts on one (generators.mkValueStringDefault errors for
    # lists), so comma-separated strings it is — which is what configobj parses
    # back into a list anyway.
    services.sabnzbd.settings = {
      misc = {
        # The *arrs reach this over the tailnet, so it cannot sit on loopback.
        # 8082 is what every download client already points at.
        # Level 5: web UI and API reachable from non-local addresses, with a
        # login required for anything not local — "not local" being decided
        # from the X-Forwarded-For header, see verify_xff_header below. Level 4
        # would demand a login locally too — stricter, breaks nothing, worth
        # revisiting.
        #
        # Note what level 5 does *not* do: interface.py's check_login() returns
        # True outright when misc.username or misc.password is empty, so this
        # only gates anything once a web login actually exists. Until then the
        # public route is protected by Cloudflare Access alone.
        inet_exposure = "api+web (locally no auth)";

        # The same paths ./dirs.nix creates and the *arrs are mapped onto,
        # taken from the options so the copies cannot drift.
        download_dir = cfg.incompletedPath;
        complete_dir = cfg.completedPath;

        # Was 777. sabnzbd chmods its finished folder to this, and 777 drops
        # the setgid bit inherited from the parent — which is why completed
        # files landed sabnzbd:sabnzbd instead of :media, and in turn why
        # syncthing could not chmod them and failed its folder hourly for
        # weeks. 2775 keeps setgid; `ignorePerms` on the syncthing side stays
        # regardless, since the far end's modes still differ.
        permissions = "2775";

        # Upstream defaults this on; it was off here and nobody remembers doing
        # it. It is what stops a proxied request from being treated as local,
        # and with inet_exposure at 5 a "local" request needs no login — so
        # with this off, anything arriving via a reverse proxy could skip
        # authentication entirely.
        verify_xff_header = true;

        # sabnzbd refuses any request whose Host header is not listed
        # ("Refused connection with hostname ..."), as DNS-rebinding
        # protection. cloudflared passes the original Host through, so the
        # public name has to be here too — it is not derived from aizen's
        # `services.cloudflared.defaultDomain` because this host does not set
        # that option (its own tunnel has no ingress).
        #
        # check_hostname() short-circuits to True as soon as a web login is
        # configured, so today this list may well be doing nothing; it starts
        # mattering the moment credentials are removed, which is the wrong time
        # to discover it was incomplete.
        host_whitelist = "shinji, shinji.sparrow-yo.ts.net, arr.arnaut.me";

        # The live value is 5 while the module defaults to 4, so the merge kept
        # writing 4 and sabnzbd kept converting back to 5 and saving — a config
        # conversion on every restart. Pin it.
        config_conversion_version = 5;
      };

      # Credentials deliberately absent: username/password stay in the live
      # ini, which the merge preserves. They only need declaring (via
      # secretValues) once allowConfigWrite goes false.
      servers."news.eweka.nl" = {
        name = "news.eweka.nl";
        displayname = "news.eweka.nl";
        host = "news.eweka.nl";
        port = 563;
        connections = 8;
        ssl = true;
        ssl_verify = "strict";
      };

      categories =
        let
          # One category per consumer folder, each landing in its own directory
          # under complete/ and below the catch-all's priority. These are the
          # same names as services.bosflix.syncedFolders, which is what gets
          # them created setgid.
          folder = order: name: {
            inherit order name;
            dir = name;
            pp = "";
            script = "";
            newzbin = "";
            priority = -100;
          };
          # These three land straight in complete/ with no directory of their own.
          plain = order: name: (folder order name) // { dir = ""; };
        in
        {
          # The catch-all. pp = 3 is repair+unpack+delete, which every other
          # category inherits by leaving pp empty.
          "*" = {
            name = "*";
            order = 0;
            pp = 3;
            script = "None";
            dir = "";
            newzbin = "";
            priority = 0;
          };
          audio = plain 0 "audio";
          software = plain 1 "software";
          prowlarr = plain 2 "prowlarr";
          tim-movies = folder 3 "tim-movies";
          tim-shows = folder 4 "tim-shows";
          mirza-movies = folder 5 "mirza-movies";
          mirza-shows = folder 6 "mirza-shows";
          mirza-music = folder 7 "mirza-music";
        };
    };

    systemd.tmpfiles.settings = {
      "sabnzbd" = {
        "/var/lib/sabnzbd".Z = {
          mode = "0755";
          inherit (sabnzbdCfg) user;
          inherit (sabnzbdCfg) group;
        };
      };
    };
  };
}
