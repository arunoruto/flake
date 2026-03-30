{ lib, ... }:
{
  imports = [
    ./desktop.nix
    ./laptop.nix
  ];

  options = {
    system.tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of tags for this Darwin system";
      example = [
        "desktop"
        "laptop"
      ];
    };
  };
}
