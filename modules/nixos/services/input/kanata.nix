{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    kanata.enable = lib.mkEnableOption "Enable kanata for keyboard remapping";
  };

  config = lib.mkIf config.kanata.enable {
    services = {
      kanata = {
        enable = true;
        keyboards."base".config = ''
          (defsrc
            caps
          )

          (defalias
            esccaps (tap-hold 100 100 esc esc)
          )

          (deflayer base
            @esccaps
          )
        '';
      };
      udev = {
        packages = with pkgs; [
          kanata
        ];
        # extraRules = ''
        #   KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
        # '';
      };
    };
  };
}
