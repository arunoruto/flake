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
        # Absent when the primary user has no home-manager (homes.enable = false).
        btop = config.home-manager.users.${config.users.primaryUser}.programs.btop or { enable = false; };
      in
      lib.mkIf btop.enable {
        security.wrappers.btop = {
          owner = "root";
          group = "root";
          source = "${btop.package}/bin/btop";
          capabilities = "cap_perfmon+ep";
        };
      }
    )
  ];
}
