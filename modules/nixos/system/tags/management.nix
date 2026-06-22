{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = lib.mkIf (lib.elem "management" config.system.tags) {
    # Fleet-management / deploy tooling. Heavy-duty machines that you deploy
    # *from* — not laptops, small PCs, or the deploy targets themselves
    # (colmena copies closures over SSH; targets don't need the binary).
    environment.systemPackages = [
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
      pkgs.deploy-rs
    ];
  };
}
