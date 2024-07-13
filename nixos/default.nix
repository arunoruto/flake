{
  imports = [
    ./desktop
    ./display
    ./environment
    ./network
    ./services
    ./system

    # ./systemd.nix
    ./pr.nix

    ./boot.nix
    ./locale.nix
    ./suid.nix
    ./security.nix

    ./user.nix
  ];
}
