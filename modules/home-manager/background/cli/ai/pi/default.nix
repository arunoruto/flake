{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./module.nix
    ./theme.nix
  ];

  programs.pi = {
    # package = lib.mkDefault (
    #   pkgs.unstable.pi-coding-agent-web or pkgs.unstable.pi-coding-agent or pkgs.pi-coding-agent
    # );
    package = pkgs.unstable.pi-coding-agent;
    tau = {
      # enable = lib.mkDefault (config.hosts.desktop.enable && !config.hosts.laptop.enable);
      port = 3939;
    };
    settings = {
      thinking = "medium";
      transport = "auto";
      theme = "stylix";
      npmCommand = [
        "${pkgs.nodejs}/bin/npm"
        "--prefix"
        "${config.home.homeDirectory}/.pi/agent/npm"
      ];
    };
    rules = ../AGENTS.md;
    extensions = {
      planner =
        config.programs.pi.package + "/lib/node_modules/pi-monorepo/examples/extensions/plan-mode";
      todo = config.programs.pi.package + "/lib/node_modules/pi-monorepo/examples/extensions/todo.ts";
    };
  };
}
