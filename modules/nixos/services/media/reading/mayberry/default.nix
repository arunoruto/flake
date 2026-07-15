{ config, lib, ... }: {
  imports = [ ./module.nix ];

  config = lib.mkMerge [
    {
      services.mayberry = {
      };
    }
    (lib.mkIf config.services.mayberry.enable {
      users.users.mayberry.extraGroups = [ "media" ];
    })
  ];
}
