{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.niri.enable {

    programs = {
      niri = {
        package = pkgs.unstable.niri;
      };
      # If you are on a laptop, you can set up brightness and volume function keys as follows:
      light.enable = true;
    };

    # environment.systemPackages = with pkgs; [
    # ];
  };
}
