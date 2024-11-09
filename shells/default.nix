pkgs: {
  python = import ./python.nix { inherit pkgs; };
  website = import ./website.nix { inherit pkgs; };
}
