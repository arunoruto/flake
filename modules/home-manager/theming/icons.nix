{
  pkgs,
  lib,
  config,
  ...
}: {
  options.theming.icons.enable = lib.mkEnableOption "Setup icons for theming";

  config = lib.mkIf config.theming.icons.enable {
    home.packages = with pkgs; [
      candy-icons
    ];
    # home.file = {
    #   ".local/share/icons/candy-icons" = {
    #     # recursive = true;
    #     source = "${candy-icons}";
    #   };
    # };
  };
}
