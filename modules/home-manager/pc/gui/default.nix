{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./chrome.nix
    ./firefox
    ./steam.nix
    ./thunderbird.nix
    ./vscode.nix
    ./zathura.nix
    ./zed.nix
  ];

  options.gui.enable = lib.mkEnableOption "Enable GUI programs";

  config = lib.mkIf config.gui.enable {
    chrome.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    steam.enable = lib.mkDefault false;
    thunderbird.enable = lib.mkDefault true;
    vscode.enable = lib.mkDefault true;
    zathura.enable = lib.mkDefault true;
    zed.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      ladybird
    ];

    # home.sessionVariables = {
    #   # Firefox
    #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
    # };
  };
}
