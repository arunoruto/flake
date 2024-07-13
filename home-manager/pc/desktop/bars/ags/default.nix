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
      # packages = with pkgs; [
      #   bun
      # ];

      file = {
        ".config/ags" = {
          recursive = true;
          source = ./config;
        };
        ".config/ags/types" = {
          recursive = true;
          source = config.lib.file.mkOutOfStoreSymlink "${config.programs.ags.finalPackage}/share/com.github.Aylur.ags/types";
          # source = "${config.programs.ags.finalPackage}/share/com.github.Aylur.ags/types";
        };
      };
    };
  };
}
