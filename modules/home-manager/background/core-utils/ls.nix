{
  config,
  lib,
  ...
}:
{
  config = {
    assertions = [
      # {
      #   assertion = (config.programs.lsd.enable && config.programs.eza.enable);
      #   message = ''
      #     Both lsd and eza are enabled.
      #     It is recommended to use only one of these 'ls' replacements to avoid confusion.
      #   '';
      # }
    ];
    warnings = lib.optional (!(config.programs.lsd.enable || config.programs.eza.enable)) ''
      Warning: Neither lsd nor eza is enabled.
      It is recommended to enable one of these 'ls' replacements for an improved terminal experience.
    '';

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
        colors = "always";
        git = true;
        icons = "auto";
        extraOptions = [
          "--group-directories-first"
          # ''--time-style='+%F %T' ''
          # "--time-style=\"+%F %T\""
          "--time-style=+%F_%T"
        ];
      };
    };
  };
}
