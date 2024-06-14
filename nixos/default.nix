{
  imports = [
    ./desktop
    ./display
    ./environment
    ./network
    ./services

    # ./systemd.nix
    ./pr.nix

    ./boot.nix
    ./locale.nix
    ./suid.nix
    ./security.nix
    ./system.nix

    ./user.nix
  ];
}
