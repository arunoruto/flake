# Shared by NixOS and Darwin: the `system.tags` option and the
# `config.lib.tags.hasTag` predicate (stylix-style `config.lib` pattern).
# The platform tag modules import this and add their own leaves.
{ config, lib, ... }:
let
  # Every tag a host may carry — the single source of truth. The enum type
  # below makes an unknown tag an evaluation error instead of a silent no-op,
  # so a typo ("worksation") or a tag that lost its consumers cannot linger.
  knownTags = {
    desktop = "graphical session: display manager, desktop environment, GUI apps";
    laptop = "portable machine: power tuning, TPM2 + yubikey";
    workstation = "stationary interactive machine: TPM2 + yubikey, remote desktop";
    development = "compilers, language servers, dev tooling";
    management = "fleet management: colmena / deploy-rs installed";
    nas = "storage box: drives, samba, NAS services";
    gaming = "game launchers (steam) and games";
    server = "headless infrastructure box: tailscale exit node/connector/SSH, no sound stack";
  };
in
{
  options.system.tags = lib.mkOption {
    type = lib.types.listOf (lib.types.enum (lib.attrNames knownTags));
    default = [ ];
    example = [
      "desktop"
      "development"
    ];
    description = ''
      Capability tags for this host. Modules gate on them via
      `config.lib.tags.hasTag "<tag>"`. Known tags:

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (tag: what: "- `${tag}` — ${what}") knownTags)}
    '';
  };

  # LHS `lib.tags` is the option; RHS `lib` is the function library.
  config.lib.tags.hasTag = import ../../lib/has-tag.nix lib config [
    "system"
    "tags"
  ];
}
