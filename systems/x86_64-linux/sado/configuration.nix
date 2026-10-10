{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.primaryUser = "mirza";

  nix = {
    settings = {
      max-jobs = 1;
      cores = 2;
      # cores/max-jobs only govern *builds*. A switch that is mostly cache hits
      # spends its time decompressing NARs instead, and the defaults (16 and 25)
      # will saturate all four cores while max-jobs sits at 1 doing nothing.
      max-substitution-jobs = 4;
      http-connections = 8;
    };
    # cores= is advisory: it sets $NIX_BUILD_CORES, but nproc inside the sandbox
    # still reports 4, so ninja/cargo/go builds ignore it. These two propagate to
    # the build processes and make them yield to anything interactive.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  # Hard ceiling for the builds that ignore $NIX_BUILD_CORES anyway: builders are
  # forked from the daemon, so they land in this unit's cgroup. Memory too: with
  # 11 GiB, a quarter of it held by services, a large build used to freeze the
  # whole box rather than fail. Above MemoryHigh the kernel reclaims from the
  # builds first; past MemoryMax it OOM-kills inside this cgroup only, so a
  # too-big build fails and the services keep running.
  systemd.services.nix-daemon.serviceConfig = {
    CPUQuota = "200%";
    MemoryHigh = "5G";
    MemoryMax = "6G";
    MemorySwapMax = "2G";
  };

  # Memory exhaustion here never reached the kernel OOM killer: with no swap the
  # box thrashed page cache and hung until power-cycled (2026-10-10, a parallel
  # all-host evaluation). zram gives reclaim somewhere to go, and oomd -- which
  # was running but watching no slice -- now kills the worst offender in a user
  # session (where evaluations run) after sustained memory pressure.
  zramSwap.enable = true;
  systemd.oomd.enableUserSlices = true;

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
  systemd.services.zfs-mount.enable = false;
  networking = {
    hostId = "b9b3aa87";
    bridges.br0 = {
      interfaces = [
        "enp1s0"
        "enp2s0"
      ];
      rstp = true;
    };
    firewall.trustedInterfaces = [ "br0" ];
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
    # Games live on flash/games: roms/ is the library retrom scans, one
    # <platform>/<game>/ folder per game. bios/ stays outside it on purpose --
    # retrom has no notion of BIOS files and would list the folder as a
    # platform; it is for the clients' emulators, via the games share.
    retrom = {
      # Off until a prebuilt retrom-service exists: retrom.cachix.org has
      # evicted its release builds, and compiling it here is too much for sado.
      enable = false;
      settings.contentDirectories = [
        {
          path = "/mnt/flash/games/roms";
          storageType = "MultiFileGame";
        }
      ];
    };
    # Retrom is the first postgres user here. The stateVersion (23.11) default
    # would start a fresh cluster on 15, which is EOL in 2027.
    postgresql.package = pkgs.postgresql_17;
    # komga.enable = true;
    # immich = {
    #   enable = true;
    #   mediaLocation = "/mnt/flash/photos";
    # };
    paperless = {
      enable = true;
      dataDir = "/mnt/flash/appdata/paperless";
      mediaDir = "/mnt/flash/documents";
    };
    explo.enable = true;
    ytdlp-bot.enable = true;
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
    # The hub's public key; the agent process reads this one itself.
    secrets."tokens/beszel-marvin".mode = "0444";
    secrets."tokens/beszel-ws" = { };
    templates."beszel-agent.env".content = ''
      TOKEN=${config.sops.placeholder."tokens/beszel-ws"}
    '';
  };
}
