{ ... }:
{
  imports = [
    ./module.nix
  ];

  services.apfel = {
    enable = true;
    port = 11434;
    # Optional: If you need CORS enabled for a web frontend
    # extraArgs = [ "--cors" ];
  };
}
