{ inputs, ... }:
{
  imports = [
    ./ghostty-module.nix
  ];

  config = {
    programs.ghostty = {
      enable = true;
      package = inputs.ghostty.packages.x86_64-linux.default;

      settings = {
        # theme = "catppuccin-mocha";
        font-size = 10;
      };
    };

    # nmt.script = ''
    #   assertFileContent \
    #     home-files/.config/ghostty/config \
    #     ${./example-config-expected}
    # '';
  };
}
