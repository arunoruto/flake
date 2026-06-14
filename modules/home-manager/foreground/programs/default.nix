{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./browsers
    ./games

    ./flatpak.nix
    ./reference-manager.nix
    # ./steam.nix
    ./thunderbird.nix
    ./vscode.nix
  ];

  options.pc.programs.enable = lib.mkEnableOption "Enable GUI programs";

  config = lib.mkIf config.pc.programs.enable {
    # programs.steam.geProton.enable = lib.mkDefault false;

    programs = {
      reference-manager.enable = lib.mkDefault true;
      thunderbird.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault false;
      zathura.enable = lib.mkDefault true;
      zed-editor = {
        enable = lib.mkDefault config.hosts.development.enable;
        package = pkgs.unstable.zed-editor;
        userSettings = {
          auto_update = false;
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
