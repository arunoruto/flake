{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.tapedeck.nixosModules.default ];

  users.primaryUser = "mirza";
  # td/td tui from the shell use the daemon's DB and socket.
  users.users.${config.users.primaryUser}.extraGroups = [ "tapedeck" ];

  nix = {
    settings = {
      # 2 x 2 fills the four cores; memory, not CPU, is the limit here.
      max-jobs = 2;
      cores = 2;
      # cores/max-jobs only govern *builds*. A switch that is mostly cache hits
      # spends its time decompressing NARs instead, and the defaults (16 and 25)
      # oversubscribe the four cores.
      max-substitution-jobs = 4;
      http-connections = 8;
    };
    # cores= is advisory: it sets $NIX_BUILD_CORES, but nproc inside the sandbox
    # still reports 4, so ninja/cargo/go builds ignore it. These two propagate to
    # the build processes and make them yield to anything interactive.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  # Builders are forked from the daemon, so they land in this unit's cgroup. With
  # 11 GiB, a quarter of it held by services, a large build used to freeze the
  # whole box rather than fail. Above MemoryHigh the kernel reclaims from the
  # builds first; past MemoryMax it OOM-kills inside this cgroup only, so a
  # too-big build fails and the services keep running.
  systemd = {
    services.nix-daemon.serviceConfig = {
      MemoryHigh = "5G";
      MemoryMax = "6G";
      MemorySwapMax = "2G";
    };
    # Face/CLIP models load into this one process and peak during the first
    # library scan; keep a runaway inside its own cgroup.
    services.immich-machine-learning.serviceConfig.MemoryMax = "3G";
    # See the zramSwap note below.
    oomd.enableUserSlices = true;
    services.zfs-mount.enable = false;
  };

  # Memory exhaustion here never reached the kernel OOM killer: with no swap the
  # box thrashed page cache and hung until power-cycled (2026-10-10, a parallel
  # all-host evaluation). zram gives reclaim somewhere to go, and oomd -- which
  # was running but watching no slice -- now kills the worst offender in a user
  # session (where evaluations run) after sustained memory pressure.
  zramSwap.enable = true;

  system.tags = [
    "nas"
    "server"
  ];

  # colmena.deployment.buildOnTarget = true;
  hosts = {
    intel = {
      enable = true;
      gpu.enable = false;
    };
    zfs.enable = true;
  };
  networking = {
    hostId = "b9b3aa87";
    bridges.br0 = {
      interfaces = [
        "enp1s0"
        "enp2s0"
      ];
      rstp = true;
    };
    firewall = {
      trustedInterfaces = [ "br0" ];
      # tapedeck's API (Subsonic apps, td remote). Avahi publishes wlo1's
      # address for sado.local too, and wlo1 isn't trusted: phones resolving
      # to it timed out. Same LAN as br0, so nothing new is exposed.
      allowedTCPPorts = [ 8687 ];
    };
    interfaces = {
      br0.useDHCP = true;
    }
    // lib.genAttrs config.networking.bridges.br0.interfaces (name: {
      useDHCP = false;
    });
    networkmanager = {
      unmanaged = map (name: "interface-name:${name}") config.networking.bridges.br0.interfaces;
      # wlo1 and br0 both sit on the LAN subnet. NetworkManager gives wifi a route
      # metric of 600, which beats the 1009 dhcpcd assigns br0, so the host answered
      # br0's own bridge members out over the wifi -- an asymmetric path the AP does
      # not hairpin, leaving host <-> member traffic dead. Push wifi below br0 so the
      # wired bridge wins and the path stays symmetric.
      settings."connection-wifi-lowprio" = {
        match-device = "type:wifi";
        "ipv4.route-metric" = 2000;
        "ipv6.route-metric" = 2000;
      };
    };
  };

  boot.kernelParams = [
    "pcie_aspm=force"
    "pcie_aspm.policy=powersupersave"
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=200M
    MaxRetentionSec=2week
    MaxFileSec=1day
  '';

  services = {
    media = {
      enable = true;
      dataDir = "/mnt/flash/appdata";
      openFirewall = true;
      libraryDirs = [
        "/mnt/flash/games/roms"
        "/mnt/flash/games/bios"
      ];
    };
    cloudflared = {
      enable = true;
      defaultDomain = "arnaut.me";
      tunnels.${config.networking.hostName}.ingress = [
        {
          hostname = "photos.${config.services.cloudflared.defaultDomain}";
          service = "http://localhost:${toString config.services.immich.port}";
        }
      ];
    };
    tailscale.tsidp = {
      enable = false;
      port = 41443;
      localPort = 41080;
    };
    stump.enable = true;
    mayberry = {
      enable = true;
      libraryPath = "/mnt/flash/books";
      branchName = "cryo-${config.networking.hostName}";
    };
    bindery.enable = true;
    # Games live on flash/games in the ES-DE layout: roms/<system>/<game file>
    # and bios/, also shared over samba. RomM manages the library; ES-DE on
    # the handhelds plays it.
    romm = {
      enable = true;
      library = "/mnt/flash/games";
      igdb.enable = true;
      retroachievements.enable = true;
      # The name that resolves for every client at home, Flatpaks included
      # (they cannot do mDNS). nginx listens on 8080 next to Traefik.
      nginx.virtualHost = "sado.fritz.box";
      # Everywhere else, through the tunnel; sign-in is Pocket ID's.
      publicHost = "rom.${config.services.cloudflared.defaultDomain}";
      oidc.enable = true;
    };
    # Replaced by RomM, which keeps the library in the ES-DE layout instead of
    # a folder per game. Kept configured in case it comes back.
    retrom = {
      # The media module patches retrom-service, so it is always built here:
      # ~30min, staying inside nix-daemon's 6G limit. Every tag bump means
      # another such build.
      enable = false;
      igdb.enable = true;
      settings.contentDirectories = [
        {
          path = "/mnt/flash/games/roms";
          storageType = "MultiFileGame";
        }
      ];
    };
    # Retrom, now RomM, brought postgres here. The stateVersion (23.11)
    # default would have started the cluster on 15, which is EOL in 2027.
    postgresql.package = pkgs.postgresql_17;
    # komga.enable = true;
    # Public at photos.arnaut.me through the tunnel. Cloudflare caps request
    # bodies at 100 MB, so long videos only upload over the LAN URL the app
    # switches to at home (http://sado.fritz.box:2283).
    immich = {
      enable = true;
      mediaLocation = "/mnt/flash/photos";
    };
    paperless = {
      enable = true;
      dataDir = "/mnt/flash/appdata/paperless";
      mediaDir = "/mnt/flash/documents";
    };
    # Replaced by tapedeck below, which fetches the same ListenBrainz
    # playlists into its own library.
    explo.enable = false;
    tapedeck = {
      enable = true;
      # Library files are shared with Plex and Samba through media.
      extraGroups = [ "media" ];
      settings = {
        # Kept apart from Lidarr's releases/.
        library = "/mnt/flash/music/tapedeck";
        listenbrainz = {
          user = "arunoruto";
          # Lets the daemon submit the listens the remote clients report.
          token_file = config.sops.secrets."tokens/listenbrainz".path;
          # The three explo used to fetch.
          playlists = [
            "weekly-jams"
            "weekly-exploration"
            "daily-jams"
          ];
        };
        download.format = "opus";
        # Lidarr's library, read-only: tracks found there aren't downloaded.
        external = {
          paths = [
            "/mnt/flash/music/releases"
            "/mnt/flash/music/singles"
          ];
          scan_interval = "1h";
          prefer_external = "ask";
        };
        # HTTP API for the remote clients on madara/tensa and Subsonic apps,
        # opened in networking.firewall above. No token: only reading,
        # streaming and scrobbling are reachable; changes stay on sado.
        # 8687: Lidarr + 1, the port tapedeck's docs use.
        server.listen = "0.0.0.0:8687";
        # Song requests: send the bot a link or "Artist - Title".
        telegram = {
          token_file = config.sops.secrets."tokens/telegram/ytdlp".path;
          allowed_users = [ 757770344 ];
        };
        sync = {
          # Not at every boot/restart: each sync also pushes to Plex.
          on_start = false;
          targets = [ "plex" ];
          # Plex runs natively here, so it sees the same paths: no path_map.
          plex = {
            url = "http://127.0.0.1:32400";
            token_file = config.sops.secrets."tokens/plex".path;
            section = "Music";
          };
        };
      };
    };
    # Replaced by tapedeck's request bot on the same token; two pollers would
    # steal each other's updates.
    ytdlp-bot.enable = false;
    # soulsync.enable = false;
    lidarr = {
      enable = true;
      openFirewall = true;
    };
    plex.enable = true;
    scrutiny.collector = {
      enable = false;
      settings.api.endpoint = "https://scrutiny.bv.e-technik.tu-dortmund.de";
    };
    # Websocket rather than the SSH method the other hosts use: the hub sits on
    # the work network and this host is behind NAT on the personal tailnet, so
    # it has to dial out. Nothing listens here and the firewall stays shut.
    beszel.agent = {
      enable = true;
      package = pkgs.unstable.beszel;
      environment = {
        LOG_LEVEL = "info";
        HUB_URL = "https://infra.bv.e-technik.tu-dortmund.de";
        # Identifies us to the hub; still required in websocket mode.
        KEY_FILE = config.sops.secrets."tokens/beszel-marvin".path;
        # Per dataset: the parent /mnt/flash holds 256K itself, so it would
        # report ~0% however full the pool actually gets.
        EXTRA_FILESYSTEMS = lib.strings.concatStringsSep "," [
          "/mnt/flash/appdata"
          "/mnt/flash/music"
          "/mnt/flash/downloads"
        ];
        # Same as on shinji: videoDrivers is modesetting, so the module's
        # driver-derived default lands on the empty list and the agent's own
        # auto-detection finds nothing. The N150's gen12 iGPU runs on i915,
        # which exposes no per-engine busy counters in sysfs - that is an xe
        # driver feature - so intel_sysfs would report frequency alone and
        # utilisation has to come off the PMU.
        GPU_COLLECTOR = [ "intel_gpu_top" ];
      };
      # EnvironmentFile, not TOKEN_FILE: systemd reads it as root, so the token
      # can stay 0400 instead of the 0444 the agent-read KEY_FILE needs.
      environmentFile = config.sops.templates."beszel-agent.env".path;
      smartmon.enable = true;
    };
    traefik.enable = true;
    syncthing.enable = true;

    # suwayomi-server = {
    #   enable = false;
    #   openFirewall = true;
    # };
    samba = {
      directories = {
        photos = {
          path = "/mnt/flash/photos";
        };
        documents = {
          path = "/mnt/flash/documents";
        };
        books = {
          path = "/mnt/flash/books";
        };
        music = {
          path = "/mnt/flash/music";
        };
        downloads = {
          path = "/mnt/flash/downloads";
        };
        games = {
          path = "/mnt/flash/games";
        };
        appdata = {
          path = "/mnt/flash/appdata";
        };
      };
      disableShares = [
        "appdata"
        "downloads"
      ];
    };
    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };

  sops = {
    secrets = {
      # The hub's public key; the agent process reads this one itself.
      "tokens/beszel-marvin".mode = "0444";
      "tokens/beszel-ws" = { };
      "tokens/plex".owner = config.services.tapedeck.user;
      "tokens/listenbrainz".owner = config.services.tapedeck.user;
      # The former ytdlp-bot token, now polled by tapedeck.
      "tokens/telegram/ytdlp" = {
        owner = config.services.tapedeck.user;
        restartUnits = [ "tapedeck.service" ];
      };
    };
    templates."beszel-agent.env".content = ''
      TOKEN=${config.sops.placeholder."tokens/beszel-ws"}
    '';
  };
}
