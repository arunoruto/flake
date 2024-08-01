{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./firefox
    # ./steam.nix
    ./thunderbird.nix
    ./vscode.nix
    ./zathura.nix
    # ./zed.nix
  ];

  home.packages = with pkgs; [
    ladybird
    # unstable.plex-desktop
    unstable.zed-editor
  ];

  # home.sessionVariables = {
  #   # Firefox
  #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
  # };
}
