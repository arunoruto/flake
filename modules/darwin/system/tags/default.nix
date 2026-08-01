# Darwin only declares the shared `system.tags` option; no tag translates
# into darwin-level settings yet. The tags still matter: home-manager's
# imports.nix reads them from osConfig to derive hosts.{desktop,laptop,...}.
# When a tag should mean something on darwin itself, add a `<tag>.nix` here
# gated on `config.lib.tags.hasTag` (see modules/nixos/system/tags/).
{ ... }:
{
  imports = [
    ../../../shared/tags.nix
  ];
}
