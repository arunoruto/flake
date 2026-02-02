# https://danth.github.io/stylix/
# This module asserts that stylix is properly configured at the system level
# Stylix is mandatory for consistent theming across all systems
{
  config,
  lib,
  ...
}:
{
  config = {
    assertions = [
      {
        assertion = config ? stylix;
        message = ''
          Stylix is not configured! Please add to your system configuration:

          For NixOS:
            imports = [ inputs.stylix.nixosModules.stylix ];

          For Darwin:
            imports = [ inputs.stylix.darwinModules.stylix ];
        '';
      }
    ];
  };
}
