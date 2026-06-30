{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.services.readarr.enable {
      warnings = [
        "services.readarr is DEPRECATED — the project has been retired (June 2025) and its metadata service is permanently offline. Consider a replacement like Bindery (github.com/vavallee/bindery)."
      ];
    })
    (lib.mkIf config.services.readarr.enable (
      (lib.arr.arrConfig "readarr" config pkgs.unstable) // { }
    ))
  ];
}
