# Also offer LVFS testing firmware, whenever fwupd is on (the default, set in
# ./default.nix).
{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.fwupd.enable {
    services.fwupd.extraRemotes = [ "lvfs-testing" ];
  };
}
