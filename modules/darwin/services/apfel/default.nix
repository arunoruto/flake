{ ... }:
{
  imports = [
    ./module.nix
  ];

  services.apfel = {
    enable = false;
    port = 11433;
    # Optional: If you need CORS enabled for a web frontend
    # extraArgs = [ "--cors" ];
  };
}
