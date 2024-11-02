{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ssh-tpm-agent;
  # socket = "/run/ssh-tpm-agent/socket";
  socket = "/var/tmp/ssh-tpm-agent.sock";
in
{
  options.services.ssh-tpm-agent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Start the SSH TPM agent on login.
      '';
    };

    package = lib.mkPackageOption pkgs "ssh-tpm-agent" { };
  };

  config = lib.mkIf cfg.enable {
    security.tpm2 = {
      enable = lib.mkDefault true;
      pkcs11.enable = lib.mkDefault true;
    };

    environment.systemPackages = [ cfg.package ];

    systemd = {
      packages = [ cfg.package ];

      # System services
      services = {
        ssh-tpm-genkeys = rec {
          description = "SSH TPM Key Generation";
          unitConfig = {
            Description = description;
            ConditionPathExists = [
              "|!/etc/ssh/ssh_tpm_host_ecdsa_key.tpm"
              "|!/etc/ssh/ssh_tpm_host_ecdsa_key.pub"
              "|!/etc/ssh/ssh_tpm_host_rsa_key.tpm"
              "|!/etc/ssh/ssh_tpm_host_rsa_key.pub"
            ];
          };
          serviceConfig = {
            Type = "oneshot";
            ExecStart = ''${cfg.package}/bin/ssh-tpm-keygen -A'';
            RemainAfterExit = "yes";
          };
        };

        ssh-tpm-agent = {
          unitConfig = {
            ConditionEnvironment = "!SSH_AGENT_PID";
            Description = "ssh-tpm-agent service";
            Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
            Wants = "ssh-tpm-genkeys.service";
            After = [
              "ssh-tpm-genkeys.service"
              "network.target"
              "sshd.target"
            ];
            Requires = "ssh-tpm-agent.socket";
          };

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/ssh-tpm-agent -d -l ${socket} --key-dir /etc/ssh";
            PassEnvironment = "SSH_AGENT_PID";
            KillMode = "process";
            Restart = "always";
          };

          wantedBy = [ "multi-user.target" ];
        };
      };
      sockets = {
        ssh-tpm-agent = {
          unitConfig = {
            Description = "SSH TPM agent socket";
            Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
          };

          socketConfig = {
            ListenStream = socket;
            SocketMode = "0600";
            Service = "ssh-tpm-agent.service";
          };

          wantedBy = [ "sockets.target" ];
        };
      };

      # User services
      user = {
        services.ssh-tpm-agent = {
          unitConfig = {
            ConditionEnvironment = "!SSH_AGENT_PID";
            Description = "ssh-tpm-agent service";
            Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
            Requires = "ssh-tpm-agent.socket";
          };

          serviceConfig = {
            Environment = "SSH_AUTH_SOCK=%t/ssh-tpm-agent.sock";
            ExecStart = "${cfg.package}/bin/ssh-tpm-agent -d";
            PassEnvironment = "SSH_AGENT_PID";
            SuccessExitStatus = "2";
            Type = "simple";
          };

          wantedBy = [ "default.target" ];
        };

        sockets.ssh-tpm-agent = {
          unitConfig = {
            Description = "SSH TPM agent socket";
            Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
          };

          socketConfig = {
            ListenStream = "%t/ssh-tpm-agent.sock";
            SocketMode = "0600";
            Service = "ssh-tpm-agent.service";
          };

          wantedBy = [ "sockets.target" ];
        };
      };
    };

    services.openssh.extraConfig = ''
      HostKeyAgent ${socket}
      HostKey /etc/ssh/ssh_tpm_host_ecdsa_key.pub
      HostKey /etc/ssh/ssh_tpm_host_rsa_key.pub
    '';
  };
}
