{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.pop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the pop email service";
    };
  };
  config = lib.mkIf config.programs.pop.enable {
    home = {
      packages = with pkgs; [
        (pop.overrideAttrs (
          final: prev: {
            patches = prev.patches ++ [
              (final.fetchpatch {
                url = "https://github.com/framegrabber/pop/commit/f7bd69218d9ab82a5f6507c6990777e91bbc195c.patch";
                hash = "";
              })
            ];
          }
        ))
      ];
      sessionVariables = {
        POP_SMTP_HOST = "unimail.tu-dortmund.de";
        POP_SMTP_PORT = 25;
        POP_SMTP_USERNAME = "mirza.arnaut@tu-dortmund.de";
        POP_SMTP_PASSWORD = "password";
        # POP_FROM = POP_SMTP_USERNAME;
        POP_FROM = "mirza.arnaut@tu-dortmund.de";
        POP_SIGNATURE = "";
      };
    };

  };
}
