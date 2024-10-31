{
  config,
  lib,
  ...
}:
{
  options.nfs.enable = lib.mkEnableOption "NFS Settings for Server and Client";

  config = lib.mkIf config.nfs.enable {
    services.nfs.server = {
      enable = true;
      # fixed rpc.statd port; for firewall
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      extraNfsdConfig = '''';
    };

    networking.firewall = {
      # for NFSv3; view with `rpcinfo -p`
      allowedTCPPorts = [
        111
        2049
        4000
        4001
        4002
        20048
      ];
      allowedUDPPorts = [
        111
        2049
        4000
        4001
        4002
        20048
      ];
    };
  };
}
