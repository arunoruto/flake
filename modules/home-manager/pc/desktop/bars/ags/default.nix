{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  options = {
    ags.enable = lib.mkEnableOption "Enable ags bar";
  };

  config = lib.mkIf config.ags.enable {
    programs.ags = {
      enable = true;
      # configDir = ../ags/config;
      # configDir = config.home.homeDirectory + "/.config/ags";

      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };

    home = {
      packages = with pkgs; [
        brightnessctl
        ddcutil
        unstable.bun
      ];

      file = {
        ".config/ags" = {
          recursive = true;
          source = ./config;
        };
        ".config/ags/css/ags-variables.scss".text = ''
          $backgroundColor: rgba(${config.lib.stylix.colors.withHashtag.base00}, 0.7);
          $backgroundColor2: rgba(${config.lib.stylix.colors.withHashtag.base00}, 0.7);
          $highlightColor: ${config.lib.stylix.colors.withHashtag.base08};
          $foregroundColor: ${config.lib.stylix.colors.withHashtag.base05};
          $foregroundColor2: ${config.lib.stylix.colors.withHashtag.base05};
        '';
        ".config/ags/types" = {
          # recursive = true;
          source = config.lib.file.mkOutOfStoreSymlink "${config.programs.ags.finalPackage}/share/com.github.Aylur.ags/types";
        };
      };
    };
  };
}
