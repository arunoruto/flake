{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./firefox
    # ./steam.nix
    ./vscode.nix
    ./zathura.nix
    # ./zed.nix
  ];

  home.packages = with pkgs; [
    ladybird
    unstable.zed-editor
  ];

  # home.sessionVariables = {
  #   # Firefox
  #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
  # };
}
