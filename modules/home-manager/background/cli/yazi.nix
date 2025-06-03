{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.yazi.enable {
    programs.yazi = {
      # package = pkgs.unstable.yazi;
      enableBashIntegration = lib.mkDefault config.programs.bash.enable;
      enableFishIntegration = lib.mkDefault config.programs.fish.enable;
      enableNushellIntegration = lib.mkDefault config.programs.nushell.enable;
      enableZshIntegration = lib.mkDefault config.programs.zsh.enable;
      settings = {
        plugin = {
          prepend_previewers = [
            {
              name = "*.md";
              run = "glow";
              # run = "${pkgs.glow}/bin/glow";
            }
            {
              mime = "text/csv";
              run = "miller";
            }
            {
              name = "*.bin";
              run = "hexyl";
            }
          ];
        };
      };
    };
    home.file = {
      ".config/yazi/plugins/glow.yazi" = {
        # recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "Reledia";
          repo = "glow.yazi";
          rev = "536185a4e60ac0adc11d238881e78678fdf084ff";
          hash = "sha256-NcMbYjek99XgWFlebU+8jv338Vk1hm5+oW5gwH+3ZbI=";
        };
      };
      ".config/yazi/plugins/miller.yazi" = {
        # recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "Reledia";
          repo = "miller.yazi";
          rev = "75f00026a0425009edb6fedcfbe893f3d2ddedf4";
          hash = "sha256-u8xadj6/s16xXUAWGezYBqnygKaFMnRUsqtjMDr6DZA=";
        };
      };
      ".config/yazi/plugins/hexyl.yazi" = {
        # recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "Reledia";
          repo = "hexyl.yazi";
          rev = "f71d9d936be1bd064f267e0d36550949901719d5";
          hash = "sha256-JYj8j0MRDoLBzBtMyY4DJkNdzI4h/HIkoRT3s2onDvs=";
        };
      };
      ".config/yazi/plugins/ouch.yazi" = {
        # recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "ndtoan96";
          repo = "ouch.yazi";
          rev = "694d149be5f96eaa0af68d677c17d11d2017c976";
          hash = "sha256-J3vR9q4xHjJt56nlfd+c8FrmMVvLO78GiwSNcLkM4OU=";
        };
      };
    };
  };
}
