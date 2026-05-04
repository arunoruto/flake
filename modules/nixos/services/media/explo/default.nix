{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./module.nix ];

  config = lib.mkIf config.services.explo.enable {
    services.explo = {
      package = lib.mkDefault pkgs.explo;
      schedules.weekly-exploration = lib.mkDefault {
        OnCalendar = "Tue 00:15:00";
        flags = "";
      };
    };

    sops = {
      secrets = {
        "services/explo/youtube-api-key" = { };
        "services/explo/system-password" = { };
        "services/explo/api-key" = { };
        "services/explo/admin-system-password" = { };
      };
      templates."explo.env" = {
        content = ''
          YOUTUBE_API_KEY=${config.sops.placeholder."services/explo/youtube-api-key"}
          SYSTEM_PASSWORD=${config.sops.placeholder."services/explo/system-password"}
          API_KEY=${config.sops.placeholder."services/explo/api-key"}
          ADMIN_SYSTEM_PASSWORD=${config.sops.placeholder."services/explo/admin-system-password"}
        '';
      };
    };
  };
}
