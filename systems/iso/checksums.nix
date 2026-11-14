# ISO + .sha256 sidecars (Ventoy-ready); what `nix build .#iso-<name>` builds.
{ config, pkgs, ... }:
{
  system.build.isoChecksums = pkgs.runCommand "iso-${config.isoImage.edition}-checksums" { } ''
    mkdir -p $out/iso
    cp ${config.system.build.isoImage}/iso/*.iso $out/iso/
    cd $out/iso
    for iso in *.iso; do
      sha256sum "$iso" > "$iso.sha256"
    done
    cd $out
    sha256sum iso/*.iso > SHA256SUMS
  '';
}
