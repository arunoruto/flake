{pkgs, ...}: {
  imports = [
    ./git.nix
    ./newsboat.nix
    ./papis.nix
    ./python.nix
  ];

  home.packages = with pkgs; [
    bws
  ];
}
