{ ... }:
{
  imports = [ ./installer.nix ];
  _module.args.hostname = "shinji";
}
