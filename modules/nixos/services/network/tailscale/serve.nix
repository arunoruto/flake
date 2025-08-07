{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.tailscale = {
    # ... existing tailscale options like enable, authKeyFile, etc.

    serve = {
      enable = lib.mkEnableOption "the Tailscale serve sidecar proxy";

      config = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = { };
        description = ''
          Declarative configuration for the Tailscale sidecar proxy (tailscale serve).
          The attribute set provided here will be converted to a JSON file and loaded
          into the tailscaled daemon.
        '';
        example = lib.literalExpression ''
          {
            TCP = {
              "443" = { HTTPS = true; };
            };
            Web = {
              "mealie.auto-generated.ts.net:443" = {
                Handlers = {
                  "/" = { Proxy = "http://127.0.0.1:9000"; };
                };
              };
            };
            AllowFunnel = {
              "mealie.auto-generated.ts.net:443" = true;
            };
          }
        '';
      };
    };
  };

  config =
    let
      cfg = config.services.tailscale;
      serveCfg = cfg.serve;
      serveConfigFile = pkgs.writeText "tailscale-serve-config.json" (builtins.toJSON serveCfg.config);
    in
    lib.mkIf cfg.enable {
      systemd.services.tailscale-serve-configurator = lib.mkIf serveCfg.enable {
        description = "Load Tailscale Serve Configuration";

        after = [ "tailscaled.service" ];
        wants = [ "tailscaled.service" ];
        wantedBy = [ "multi-user.target" ];
        # path = [
        #   pkgs.bash
        #   pkgs.coreutils
        #   cfg.package
        # ];

        serviceConfig = {
          Type = "oneshot";

          ExecStart = ''
            ${pkgs.runtimeShell} -c "${pkgs.coreutils}/bin/cat ${serveConfigFile} | ${cfg.package}/bin/tailscale serve set-raw"
          '';

          ExecStop = "${cfg.package}/bin/tailscale serve reset";
          RemainAfterExit = true;
        };
      };
    };
}
