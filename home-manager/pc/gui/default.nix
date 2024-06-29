{config, ...}: {
  imports = [
    ./firefox
    # ./steam.nix
    ./zathura.nix
  ];

  # home.sessionVariables = {
  #   # Firefox
  #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
  # };
}
