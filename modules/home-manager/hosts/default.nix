{ lib, ... }:
{
  imports = [
    # ./kyuubi
    # ./zangetsu
  ];

  options = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "nixos";
      description = "Set hostname of the device that is used for host specific home config.";
    };
  };
}
