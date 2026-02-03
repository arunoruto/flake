{ lib, ... }:
{
  config = {
    security.pam.services.sudo_local = {
      enable = lib.mkDefault true;
      touchIdAuth = lib.mkDefault true;
    };
  };
}
