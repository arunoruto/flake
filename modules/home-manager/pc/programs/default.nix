{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./chrome.nix
    ./firefox
    ./steam.nix
    ./thunderbird.nix
    ./vscode.nix
    ./zathura.nix
    ./zed.nix
  ];

  options.pc.programs.enable = lib.mkEnableOption "Enable GUI programs";

  config = lib.mkIf config.pc.programs.enable {
    chrome.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    steam.enable = lib.mkDefault false;
    vscode.enable = lib.mkDefault true;
    zathura.enable = lib.mkDefault true;
    zed.enable = lib.mkDefault true;

    programs = {
      thunderbird.enable = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      vlc
      # unstable.vscode

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
      zoom-us
      zotero

      # ladybird
      # unstable.spacedrive
    ];

    # home.sessionVariables = {
    #   # Firefox
    #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
    # };
  };
}
