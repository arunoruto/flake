{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "management") {
    # Fleet-management / deploy tooling. Heavy-duty machines that you deploy
    # *from* — not laptops, small PCs, or the deploy targets themselves
    # (colmena copies closures over SSH; targets don't need the binary).
    environment.systemPackages = [
      pkgs.unstable.colmena
    ];
  };
}
