{
  config,
  lib,
  ...
}:
{
  imports = [
    ./gpu.nix
    ./oneapi.nix
  ];

  options.hosts.intel.enable = lib.mkEnableOption "Setup intel tools";

  config = lib.mkMerge [
    (lib.mkIf config.hosts.intel.enable {
      # hosts.intel.oneapi.enable = lib.mkDefault false;
    })
    (
      let
        inherit (config.users) primaryUser;
      in
      lib.mkIf config.home-manager.users.${primaryUser}.programs.btop.enable {
        security.wrappers.btop = {
          owner = "root";
          group = "root";
          source = "${config.home-manager.users.${primaryUser}.programs.btop.package}/bin/btop";
          capabilities = "cap_perfmon+ep";
        };
      }
    )
  ];
}
