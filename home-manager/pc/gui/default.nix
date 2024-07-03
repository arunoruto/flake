{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./firefox
    # ./steam.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    ladybird
  ];

  # home.sessionVariables = {
  #   # Firefox
  #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
  # };
}
