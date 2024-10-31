{
  config,
  lib,
  ...
}:
{
  options = {
    davmail.enable = lib.mkEnableOption "Enable DavMail for exchange support";
  };

  config = lib.mkIf config.davmail.enable {
    services.davmail = {
      enable = true;
      # url = "https://outlook.tu-dortmund.de/owa";
      url = "https://outlook.tu-dortmund.de/ews/exchange.asmx";
      config = {
        # davmail.allowRemote = true;
      };
    };
  };
}
