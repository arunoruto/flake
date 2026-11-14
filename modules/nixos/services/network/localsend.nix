{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.localsend.enable {
    programs.localsend = {
      # ponytail: unstable's localsend dropped zlib and fails to start with a missing libz.so.1;
      # drop the override once the upstream fix reaches nixos-unstable.
      package = pkgs.unstable.localsend.overrideAttrs (old: {
        runtimeDependencies = old.runtimeDependencies or [ ] ++ [ pkgs.unstable.zlib ];
      });
      openFirewall = true;
    };
  };
}
