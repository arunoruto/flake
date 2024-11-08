{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.helix.nix.enable = lib.mkEnableOption "Helix Nix config";

  config = lib.mkIf config.helix.nix.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${lib.getExe pkgs.unstable.nixfmt-rfc-style}";
            # formatter.command = "${pkgs.alejandra}/bin/alejandra";
            language-servers = [
              "nixd"
              "nil"
            ];
          }
        ];
        language-server = {
          nixd = {
            command = "${lib.getExe pkgs.unstable.nixd}";
            config = config.nixd-config;
          };
        };
      };
      extraPackages = with pkgs; [
        nil
        # alejandra
      ];
    };
  };
}
