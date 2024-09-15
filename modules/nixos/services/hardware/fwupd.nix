{
  config,
  lib,
  ...
}: {
  options = {
    fwupd.enable = lib.mkEnableOption "Firmware update manager";
  };

  config = lib.mkIf config.fwupd.enable {
    services.fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"];
    };
  };
}
