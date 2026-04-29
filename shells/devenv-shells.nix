# Devenv shell configurations
# This file defines the module configurations for devenv-based shells.
# Separated from shell definitions for clarity and maintainability.
{ self }:
{
  python = [
    self.devenvModules.core
    self.devenvModules.helix
    self.devenvModules.python
    ({ ... }: {
      development.languages.python.enable = true;
      programs.helix.enable = true;
      devenv.root = "/Users/mirza/.config/flake";
    })
  ];
  
  # Add more devenv shells here as needed:
  # go = [
  #   self.devenvModules.core
  #   self.devenvModules.helix
  #   # Add go module when created
  #   ({ ... }: {
  #     development.languages.go.enable = true;
  #     programs.helix.enable = true;
  #     devenv.root = "/Users/mirza/.config/flake";
  #   })
  # ];
}
