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
      settings = {
        open = {
          prepend_rules = [
            {
              mime = "application/pdf";
              use = "tdf";
            }
          ];
        };
        opener = {
          tdf = [
            {
              run = ''tdf "$1"'';
              block = true;
              for = "unix";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            {
              mime = "application/pdf";
              run = ''piper -- pdftotext -l 1 "$1" -'';
            }
            {
              mime = "text/markdown";
              run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
            }
            {
              mime = "text/csv";
              # run = "mlr";
              run = ''piper -- mlr --icsv --opprint --key-color darkcyan --value-color grey70 cat "$1"'';
            }
          ];
          append_previewers = [
            {
              mime = "*";
              run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
            }
          ];
        };
      };
      # extraPackages = with pkgs; [
      #   glow
      #   miller
      #   ouch
      #   hexyl
      # ];
      plugins = {
        inherit (pkgs.yaziPlugins)
          glow
          miller
          ouch
          piper
          ;
      };
      enableBashIntegration = lib.mkDefault config.programs.bash.enable;
      enableFishIntegration = lib.mkDefault config.programs.fish.enable;
      enableNushellIntegration = lib.mkDefault config.programs.nushell.enable;
      enableZshIntegration = lib.mkDefault config.programs.zsh.enable;

      shellWrapperName = lib.mkDefault "y";
    };
  };
}
