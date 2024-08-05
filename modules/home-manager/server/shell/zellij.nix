{
  config,
  lib,
  ...
}: {
  options.zellij.enable = lib.mkEnableOption "Enable the rust tmux alternative";

  config = lib.mkIf config.zellij.enable {
    programs.zellij = {
      enable = true;
      settings = {
      };
    };
  };
}
