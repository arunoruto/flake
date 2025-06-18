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
      enable = true;
      mcp = {
        enable = true;
        package = inputs.nixai.packages."${pkgs.system}".nixai;
        aiProvider = "copilot";
        aiModel = "gpt-4";
      };
    };
  };
}
