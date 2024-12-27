{ inputs, config, ... }:
{
  imports = [
    ./ghostty-module.nix
  ];

  config = {
    programs.ghostty = {
      package = inputs.ghostty.packages.x86_64-linux.default;

      settings = {
        theme = "stylix";
        # background-blur-radius = 20;
        background-opacity = config.stylix.opacity.terminal;
        font-family = config.stylix.fonts.monospace.name;
        font-size = config.stylix.fonts.sizes.terminal;
        window-height = config.terminals.height;
        window-width = config.terminals.width;
        keybind = [
          "alt+enter=toggle_fullscreen"
          "alt+h=previous_tab"
          "alt+l=next_tab"
        ];
      };
    };

    # nmt.script = ''
    #   assertFileContent \
    #     home-files/.config/ghostty/config \
    #     ${./example-config-expected}
    # '';

    home.file.".config/ghostty/themes/stylix".text = with config.lib.stylix.colors.withHashtag; ''
      palette = 0=${base03}
      palette = 1=${base08}
      palette = 2=${base0B}
      palette = 3=${base0A}
      palette = 4=${base0D}
      palette = 5=${base0F}
      palette = 6=${base0C}
      palette = 7=${base05}
      palette = 8=${base04}
      palette = 9=${base08}
      palette = 10=${base0B}
      palette = 11=${base0A}
      palette = 12=${base0D}
      palette = 13=${base0F}
      palette = 14=${base0C}
      palette = 15=${base05}
      background = ${base00}
      foreground = ${base05}
      cursor-color = ${base06}
      selection-background = ${base02}
      selection-foreground = ${base05}
    '';
  };
}
