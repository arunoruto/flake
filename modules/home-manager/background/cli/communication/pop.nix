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
        (pop.overrideAttrs {
          patches = [
            (pkgs.fetchpatch {
              name = "pop-credentialless.patch";
              url = "https://patch-diff.githubusercontent.com/raw/charmbracelet/pop/pull/144.patch";
              hash = "sha256-wjF2fIoU5/ALtTwH24oFhieXVvMjJodHrNdYDrvXVqA=";
            })
          ];
        })
      ];
      sessionVariables = {
        POP_SMTP_HOST = "unimail.tu-dortmund.de";
        POP_SMTP_PORT = 25;
        # POP_SMTP_USERNAME = "mirza.arnaut@tu-dortmund.de";
        # POP_SMTP_PASSWORD = "password";
        # POP_FROM = POP_SMTP_USERNAME;
        POP_FROM = "mirza.arnaut@tu-dortmund.de";
        POP_SIGNATURE = "";
      };
    };

  };
}
