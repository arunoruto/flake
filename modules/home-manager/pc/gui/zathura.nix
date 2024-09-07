{
  lib,
  config,
  ...
}: {
  options.zathura.enable = lib.mkEnableOption "Enable Zathura, a configurable PDF editor";

  config = lib.mkIf config.zathura.enable {
    programs.zathura = {
      enable = true;
    };
  };
}
