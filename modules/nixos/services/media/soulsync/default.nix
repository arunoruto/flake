{ ... }:
{
  imports = [ ./module.nix ];
  config = {
    services.soulsync = {
      openFirewall = true; # Recommended so you can access the UI from your network!
    };
  };
}
