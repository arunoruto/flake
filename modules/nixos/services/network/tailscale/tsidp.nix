{
  config,
  lib,
  ...
}:
{
  options.services.tailscale.tsidp = {
    enable = lib.mkEnableOption "the Tailscale Identity Provider (tsidp) service";

    package = lib.mkOption {
      type = lib.types.package;
      default = config.services.tailscale.package;
      defaultText = "config.services.tailscale.package";
      description = "The (tailscale) package that provides the tsidp binary.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 443;
      description = "Port number";
    };

    localPort = lib.mkOption {
      type = lib.types.int;
      default = -1;
      description = "Local port number";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}-tsidp";
      description = "The hostname to use for the tsidp node (TS_HOSTNAME).";
    };

    useLocalTailscaled = lib.mkOption {
      type = lib.types.bool;
      default = config.services.tailscale.enable;
      description = "Use local tailscaled instead of tsnet.";
    };

    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Verbose logs.";
    };

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        A path to a file containing the Tailscale auth key.
        The file content should be a single line: TS_AUTHKEY=tskey-auth-...
      '';
      example = "/etc/nixos/secrets/tsidp.env";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the TSIDP port and local port in the firewall.";
    };
  };

  config =
    let
      cfg = config.services.tailscale.tsidp;
      workDir = "/var/lib/tsidp";
    in
    lib.mkIf cfg.enable {
      # Open the firewall port if the user requested it.
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
        [ cfg.port ] ++ lib.optionals (cfg.localPort > 0) [ cfg.localPort ]
      );

      # Define the systemd service.
      systemd.services.tsidp = {
        description = "Tailscale Identity Provider Service";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = "root";
          Group = "root";
          Type = "simple";

          # Use the package specified in the options.
          ExecStart =
            "${cfg.package}/bin/tsidp ${
              lib.strings.concatStringsSep " " [
                "-hostname ${cfg.hostname}"
                "-port ${builtins.toString cfg.port}"
                "-local-port ${builtins.toString cfg.localPort}"
              ]
            }"
            + lib.optionalString (cfg.useLocalTailscaled) " -use-local-tailscaled"
            + lib.optionalString (cfg.verbose) " -verbose";

          Restart = "always";
          RestartSec = "5s";

          # Create /var/lib/tsidp with 0700 permissions, owned by root:root.
          StateDirectory = "tsidp";
          WorkingDirectory = workDir;

          # Set environment variables from the module options.
          Environment = [
            "TS_HOSTNAME=${cfg.hostname}"
            "TS_STATE_DIR=${workDir}"
            "TS_USERSPACE=false"
            "TAILSCALE_USE_WIP_CODE=1"
          ];
        }
        // lib.optionalAttrs (cfg.authKeyFile != null) {
          # Use the auth key file specified in the options.
          EnvironmentFile = cfg.authKeyFile;
        };
      };
    };
}
