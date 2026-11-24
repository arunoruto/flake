# How this flake upgrades itself, whenever `system.autoUpgrade` is on (the
# desktop tag turns it on).
{
  config,
  lib,
  self,
  ...
}:
{
  config = lib.mkMerge [
    {
      # The commit a system was built from: `nixos-version --configuration-revision`.
      # A dirty tree gives `<rev>-dirty`, which the upgrade guard refuses to replace.
      system.configurationRevision = self.rev or self.dirtyRev or null;
    }
    (lib.mkIf config.system.autoUpgrade.enable {
      system.autoUpgrade = {
        dates = "04:00";
        randomizedDelaySec = "15min";
        # Follow the repo's main branch (with its committed flake.lock, validated
        # by CI) instead of a frozen store snapshot of the source. Referencing
        # inputs.self.outPath here would also embed the whole flake source in the
        # system closure, rebuilding every desktop host on any repo change.
        flake = "github:arunoruto/flake";
        flags = [ "-L" ];
      };
    })
  ];
}
