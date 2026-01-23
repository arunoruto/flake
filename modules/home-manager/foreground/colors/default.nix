{
  lib,
  pkgs,
  config,
  ...
}:
{
  # config = lib.mkIf (!(lib.elem "headless" config.system.tags)) {
  config = lib.mkIf (!config.hosts.headless.enable) {
    home.file = {
      ".local/share/icc/framework13-intel.icm".source = ./BOE_CQ_______NE135FBM_N41_01.icm;
      # ".local/share/icc/framework13-amd.icm".source = ./BOE_CQ_______NE135FBM_N41_03.icm;
      # ".local/share/icc/framework13-intel-ultra.icm".source = ./BOE0CB4.icm;
    };
    # environment.systemPackages = with pkgs; [
    #   (writeText {
    #     name = "framework13-intel.icm";
    #     text = builtins.readFile ./BOE_CQ_______NE135FBM_N41_01.icm;
    #   })
    #   # (writeText {
    #   #   name = "framework13-amd.icm";
    #   #   text = builtins.readFile ./BOE_CQ_______NE135FBM_N41_03.icm;
    #   # })
    #   # (writeText {
    #   #   name = "framework13-intel-ultra.icm";
    #   #   text = builtins.readFile ./BOE0CB4.icm;
    #   # })
    # ];
  };
}
