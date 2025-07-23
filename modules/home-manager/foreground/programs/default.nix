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
    zathura.enable = lib.mkDefault true;

    programs = {
      thunderbird.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault false;
      zed-editor = {
        enable = lib.mkDefault false;
        package = pkgs.unstable.zed-editor;
      };
    };

    home.packages = with pkgs; [
      vlc

      discord
      # jabref
      # libsForQt5.kdenlive
      libsForQt5.okular
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
    ];
  };
}
