{
  config,
  lib,
  ...
}: {
  options.ssh.enable = lib.mkEnableOption "Enable personal SSH settings";

  config = lib.mkIf config.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        hublab = {
          host = "gitlab.com github.com";
          identitiesOnly = false;
          identityFile = [
            "~/.ssh/id_sops"
          ];
        };
      };
      extraConfig = ''
        Host kyuubi.tail
            HostName kyuubi
            User mar
            ForwardX11 yes
        Host ultron.tail
            Hostname ultron
            User mar
            ForwardX11 yes
        Host jabba.tail
            Hostname jabba
            User mar
            ForwardX11 yes
      '';
    };
  };
}
