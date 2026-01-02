{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./browsers

    ./flatpak.nix
    # ./steam.nix
    ./thunderbird.nix
    ./vscode.nix
    ./zathura.nix
  ];

  options.pc.programs.enable = lib.mkEnableOption "Enable GUI programs";

  config = lib.mkIf config.pc.programs.enable {
    # steam.enable = lib.mkDefault false;

    programs = {
      thunderbird.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault false;
      zathura.enable = lib.mkDefault true;
      zed-editor = {
        enable = lib.mkDefault false;
        package = pkgs.unstable.zed-editor;
        userSettings = {
          auto_update = false;
          theme = {
            mode = "system";
            dark = "Gruvbox Dark";
            light = "Gruvbox Light";
          };
          hour_format = "hour24";
          vim_mode = false;
        };
      };
    };

    home.packages = lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") (
      with pkgs;
      [
        vlc

        discord
        fluffychat
        # jabref
        # libsForQt5.kdenlive
        kdePackages.okular
        # mailspring
        # masterpdfeditor
        # mprime
        # unstable.mqtt-explorer
        plex-desktop
        remmina
        # rustdesk
        # zoom-us
        zotero

        # ladybird
        # unstable.spacedrive
      ]
    );
  };
}
