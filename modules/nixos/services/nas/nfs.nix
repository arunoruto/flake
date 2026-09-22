# Fixed NFSv3 ports and the matching firewall holes, whenever the NFS server
# is on. (Server only: nothing here configures NFS client mounts.)
{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.nfs.server.enable {
    services.nfs.server = {
      # fixed rpc.statd port; for firewall
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      extraNfsdConfig = "";
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
