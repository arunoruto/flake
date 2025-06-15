{
  inputs,
  config,
  lib,
  ...
}:
{
  # imports = [ inputs.nixai.homeManagerModules.default ];
  # config = lib.mkIf config.foreground.enable {
  #   services.nixai = {
  #     enable = false;
  #     mcp = {
  #       enable = true;
  #       aiProvider = "copilot";
  #       aiModel = "gpt-4";
  #     };
  #   };
  # };
}
