{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.theming.icons.enable = lib.mkEnableOption "Setup icons for theming";

  config = lib.mkIf config.theming.icons.enable {
    home.packages = with pkgs; [
      (unstable.candy-icons.overrideAttrs (old: {
        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/icons/candy-icons
          cp -r . $out/share/icons/candy-icons
          ln -s $out/share/icons/candy-icons/apps/scalable/zen.svg $out/share/icons/candy-icons/apps/scalable/zen-browser.svg
          gtk-update-icon-cache $out/share/icons/candy-icons

          runHook postInstall
        '';
      }))
    ];
    # home.file = {
    #   ".local/share/icons/candy-icons" = {
    #     # recursive = true;
    #     source = "${candy-icons}";
    #   };
    # };
  };
}
