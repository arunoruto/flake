{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.mods.enable {
    programs.mods.settings = {
      apis = {
        copilot = {
          base-url = "https://api.githubcopilot.com";
          models = {

            "gpt-4o-2024-05-13" = {
              aliases = [
                "4o-2024"
                "4o"
                "gpt-4o"
              ];
              max-input-chars = 392000;
            };
            "gpt-4" = {
              aliases = [ "4" ];
              max-input-chars = 24500;
            };
            "gpt-3.5-turbo" = {
              aliases = [ "35t" ];
              max-input-chars = 12250;
            };
            "o1-preview-2024-09-12" = {
              aliases = [
                "o1-preview"
                "o1p"
              ];
              max-input-chars = 128000;
            };
            "o1-mini-2024-09-12" = {
              aliases = [
                "o1-mini"
                "o1m"
              ];
              max-input-chars = 128000;
            };
            "claude-3.5-sonnet" = {
              aliases = [
                "claude3.5-sonnet"
                "sonnet-3.5"
                "claude-3-5-sonnet"
              ];
              max-input-chars = 680000;
            };
          };
        };
      };

    };
  };
}
