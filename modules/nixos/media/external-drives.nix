{
  config,
  lib,
  ...
}:
{

  options.media.external-drives.enable = lib.mkEnableOption "Mount external drives automagically";

  config = lib.mkIf config.media.external-drives.enable {
    services = {
      devmon.enable = true;
      udisks2.enable = true;
      udev.extraRules = ''
        # UDISKS_FILESYSTEM_SHARED
        # ==1: mount filesystem to a shared directory (/media/VolumeName)
        # ==0: mount filesystem to a private directory (/run/media/$USER/VolumeName)
        # See udisks(8)
        ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"

        SUBSYSTEM=="block", ATTRS{model}=="TOSHIBA DT01ABA300", ENV{ID_ATA_SMART_IS_AVAILABLE}="0", ENV{ID_ATA}="0"
      '';
    };

    systemd.tmpfiles.settings = {
      "media"."/media".D = {
        mode = "0755";
        user = "root";
        group = "root";
      };
    };
  };
}
