{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.shells.enable = lib.mkEnableOption "Helix shells config";

  config = lib.mkIf config.helix.shells.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "bash";
            auto-format = true;
            formatter.command = "shfmt";
          }
        ];
      };
      extraPackages = with pkgs; [
        bash-language-server
        shfmt
      ];
    };
  };
}
