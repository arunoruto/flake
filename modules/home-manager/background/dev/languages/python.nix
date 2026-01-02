{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.dev;
in
{
  programs.dev.languages.python = {
    tags = [ "python" ];
    extensions = [
      ".py"
      ".pyi"
    ];
    roots = [
      "setup.py"
      "setup.cfg"
      "pyproject.toml"
      "pyrightconfig.json"
      "Poetry.lock"
      "uv.lock"
      "requirements.txt"
    ];

    autoFormat = true;
    lspServers = [
      "pyright"
    ]
    ++ lib.optionals cfg.lsp.servers.ruff.enable [ "ruff" ]
    ++ lib.optionals cfg.lsp.servers.ty.enable [ "ty" ]
    ++ lib.optionals cfg.lsp.servers.sourcery.enable [ "sourcery" ];

    formatter = {
      package = pkgs.bash;
      command = lib.getExe pkgs.bash;
      args = [
        "-c"
        "ruff check --select I --fix - | ruff format -"
      ];
    };

    packages =
      (with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            debugpy
          ]
        ))
        pyright
      ])
      ++ [
        (if config.programs.ruff.enable then config.programs.ruff.package else pkgs.unstable.ruff)
        (if config.programs.ty.enable then config.programs.ty.package else pkgs.unstable.ty)
      ];
  };
}
