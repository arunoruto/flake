{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.services.readarr.enable (
    (lib.arr.arrConfig "readarr" config pkgs.unstable) // { }
  );
}
