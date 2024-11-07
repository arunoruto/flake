{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.neorg-overlay.overlays.default
  ];

  programs.nixvim = {
    plugins = {
      neorg = {
        enable = true;
        modules = {
          "core.defaults".__empty = null;
          "core.concealer" = {
            config = {
              icon_preset = "basic";
            };
          };
          "core.dirman" = {
            config = {
              workspaces = {
                notes = "~/Documents/notes";
              };
              default_workspace = "notes";
            };
          };
        };
      };
    };
  };
}
