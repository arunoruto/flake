{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.beszel.agent;
in
{
  disabledModules = [ "services/monitoring/beszel-agent.nix" ];

  meta.maintainers = with lib.maintainers; [
    BonusPlay
    arunoruto
  ];

  options.services.beszel.agent = {
    enable = lib.mkEnableOption "beszel agent";
    package = lib.mkPackageOption pkgs "beszel" { };
    openFirewall = (lib.mkEnableOption "") // {
      description = "Whether to open the firewall port (default 45876).";
    };

    environment = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          EXTRA_FILESYSTEMS = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = ''
              lib.strings.concatStringsSep "," [
                "sdb"
                "sdc1"
                "mmcblk0"
                "/mnt/network-share"
              ];
            '';
            description = ''
              Comma separated list of additional filesystems to monitor extra disks.
              See <https://beszel.dev/guide/additional-disks>.
            '';
          };
          KEY_FILE = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Public SSH key(s) from a file instead of an environment variable. Provided in the hub.
            '';
          };
          TOKEN_FILE = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              WebSocket token from a file instead of an environment variable. Provided in the hub.
            '';
          };
        };
      };
      default = { };
      description = ''
        Environment variables for configuring the beszel-agent service.
        This field will end up public in /nix/store, for secret values use `environmentFile`.
      '';
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File path containing environment variables for configuring the beszel-agent service in the format of an EnvironmentFile. See {manpage}`systemd.exec(5)`.
      '';
    };
    extraPath = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Extra packages to add to beszel path (such as nvidia-smi or rocm-smi).
      '';
    };
    smartmontools = lib.mkOption {
      default = true;
      example = false;
      description = "Include smartmontools in the Beszel agent path for disk monitoring and add the agent to the disk group.";
      type = lib.types.bool;
    };
    deviceAllow = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "/dev/sda"
        "/dev/sdb"
        "/dev/nvme0"
      ];
      description = ''
        List of device paths to allow access to for SMART monitoring.
        This is only needed if the ambient capabilities are not sufficient.
        Devices will be granted read-only access.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.beszel-agent = {
      description = "Beszel Server Monitoring Agent";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = cfg.environment;
      path =
        cfg.extraPath
        ++ lib.optionals cfg.smartmontools [ pkgs.smartmontools ]
        ++ lib.optionals (builtins.elem "nvidia" config.services.xserver.videoDrivers) [
          (lib.getBin config.hardware.nvidia.package)
        ]
        ++ lib.optionals (builtins.elem "amdgpu" config.services.xserver.videoDrivers) [
          (lib.getBin pkgs.rocmPackages.rocm-smi)
        ]
        ++ lib.optionals (builtins.elem "intel" config.services.xserver.videoDrivers) [
          (lib.getBin pkgs.intel-gpu-tools)
        ];

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/beszel-agent
        '';

        EnvironmentFile = cfg.environmentFile;

        # adds ability to monitor docker/podman containers
        SupplementaryGroups = [
          "messagebus"
        ]
        ++ lib.optionals cfg.smartmontools [ "disk" ]
        ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
        ++ lib.optionals (
          config.virtualisation.podman.enable && config.virtualisation.podman.dockerSocket.enable
        ) [ "podman" ];

        DynamicUser = true;
        User = "beszel-agent";
        # Capabilities needed for SMART monitoring
        AmbientCapabilities = lib.mkIf cfg.smartmontools [
          "CAP_SYS_RAWIO"
          "CAP_SYS_ADMIN"
        ];
        CapabilityBoundingSet = lib.mkIf cfg.smartmontools [
          "CAP_SYS_RAWIO"
          "CAP_SYS_ADMIN"
        ];
        # Device access for SMART monitoring
        DeviceAllow = lib.mkIf (cfg.smartmontools && cfg.deviceAllow != [ ]) (
          map (device: "${device} r") cfg.deviceAllow
        );
        LockPersonality = true;
        # NoNewPrivileges = !cfg.smartmontools;
        NoNewPrivileges = true;
        PrivateDevices = lib.mkForce false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "30s";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
        UMask = 27;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (
        if (builtins.hasAttr "PORT" cfg.environment) then
          (lib.strings.toInt cfg.environment.PORT)
        else
          45876
      )
    ];

    services.udev.extraRules = lib.optionalString cfg.smartmontools ''
      # Change NVMe devices to disk group ownership for S.M.A.R.T. monitoring
      KERNEL=="nvme[0-9]*", GROUP="disk", MODE="0660"
    '';
  };
}
