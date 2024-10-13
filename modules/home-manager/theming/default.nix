{
  lib,
  config,
  ...
}: {
  imports = [
    ./icons.nix
    ./stylix.nix
  ];

  options.theming.enable = lib.mkEnableOption "Setup local theming";

  config = lib.mkIf config.theming.enable {
    theming = {
      icons.enable = lib.mkDefault true;
      # stylix.enable = lib.mkDefault true;
    };
  };
}
