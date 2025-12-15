{
  config,
  pkgs,
  lib,
  ...
}:
{
  assertions = [
    {
      assertion = (with config.programs; lsd.enable && eza.enable);
      message = ''
        Both lsd and eza are enabled.
        It is recommended to use only one of these 'ls' replacements to avoid confusion.
      '';
    }
  ];
  warnings =
    if (with config.programs; !(lsd.enable || eza.enable)) then
      [
        ''
          Warning: Neither lsd nor eza is enabled.
          It is recommended to enable one of these 'ls' replacements for an improved terminal experience.
        ''
      ]
    else
      [ ];

  programs = {
    lsd = {
      # enableAliases = true;
      # enableBashIntegration = config.programs.bash.enable;
      # enableFishIntegration = config.programs.fish.enable;
      # enableZshIntegration = config.programs.zsh.enable;
      settings = {
        ignore-globs = [
          ".DS_Store"
        ];
        blocks = [
          "permission"
          "user"
          "group"
          "size"
          "date"
          "git"
          "name"
        ];
        date = "+%F %T";
        sorting = {
          dir-grouping = "first";
        };
      };
    };

    eza = {
      color = "always";
      git = true;
      icons = true;
      extraOptions = [ "--group-directories-first" ];
    };
  };
}
