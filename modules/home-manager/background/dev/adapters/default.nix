{ lib, config, ... }:
{
  config = lib.mkIf config.programs.helix.enable {
    programs.dev = {
      enable = true;

      adapters = {
        helix.enable = true;
        opencode.enable = lib.mkDefault true;
      };

      groups.markup.enable = lib.mkDefault true;

      languages = {
        markdown.enable = lib.mkDefault true;
        nix.enable = lib.mkDefault true;

        bash.enable = lib.mkDefault config.hosts.development.enable;
        fish.enable = lib.mkDefault config.hosts.development.enable;
        nu.enable = lib.mkDefault config.hosts.development.enable;

        latex.enable = lib.mkDefault config.hosts.development.enable;
        typst.enable = lib.mkDefault config.hosts.development.enable;

        python.enable = lib.mkDefault config.hosts.development.enable;
        go.enable = lib.mkDefault config.hosts.development.enable;
        fortran.enable = lib.mkDefault config.hosts.development.enable;
        matlab.enable = lib.mkDefault config.hosts.development.enable;
        julia.enable = lib.mkDefault false;
      };

      lsp = {
        servers = {
          codebook.enable = lib.mkDefault config.hosts.development.enable;

          ltex.enable = lib.mkDefault config.hosts.development.enable;
          harper.enable = lib.mkDefault false;

          copilot.enable = lib.mkDefault false;
          lsp-ai.enable = lib.mkDefault false;
        };

        ltex.ngram.enable = lib.mkDefault (
          config.hosts.development.enable && (config._module.args ? nixosConfig)
        );
      };
    };
  };
}
