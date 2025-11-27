{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.nixai.homeManagerModules.default ];
  config = lib.mkIf config.foreground.enable {
    services.nixai = {
      enable = false;
      mcp = {
        enable = false;
        package = inputs.nixai.packages."${pkgs.stdenv.hostPlatform.system}".nixai;
        aiProvider = "copilot";
        aiModel = "gpt-4";
      };
    };
  };
}
