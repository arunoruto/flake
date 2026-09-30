{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.superfile;

  # superfile can only write the last dir to a file on quit; a shell function
  # has to source it. Without that, a plain alias is enough.
  cdOnQuit = (cfg.settings.cd_on_quit or false) && config.programs.fish.enable;
in
{
  imports = [
    ./theme.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.superfile = {
      firstUseCheck = false;
      zoxidePackage = config.programs.zoxide.package;

      # Per-key defaults, so a single hotkey can be overridden.
      hotkeys = lib.mapAttrs (_: lib.mkDefault) (import ./vim-hotkeys.nix);

      settings = {
        # Only the keys set here are written; superfile fills in defaults for
        # the rest, so silence its "missing fields" warning.
        ignore_missing_fields = true;

        # Updates come through nix.
        auto_check_update = false;

        # Write the last directory on quit; the `spf` function below cd's into it.
        cd_on_quit = lib.mkDefault true;

        default_open_file_preview = true;
        show_image_preview = true;
        # bat is themed by stylix; the builtin chroma previewer is not.
        code_previewer = lib.mkIf config.programs.bat.enable "bat";

        nerdfont = true;
        metadata = true;

        # superfile resolves *every* start path through `zoxide query`, so a
        # bare "." jumps to the top-ranked dir containing a dot. The `spf`
        # wrapper below hands it absolute paths, which zoxide passes through.
        zoxide_support = config.programs.zoxide.enable;
      };
    };

    home.shellAliases.spf = lib.mkIf (!cdOnQuit) "superfile";

    programs.fish.functions.spf = lib.mkIf cdOnQuit {
      description = "superfile, cd into the last directory on quit";
      body = ''
        # Existing paths go in absolute so zoxide leaves them alone; anything
        # else is a zoxide keyword (`spf proj`), like `z`.
        set -l args
        for arg in $argv
            if test -e "$arg"
                set -a args (path resolve -- $arg)
            else
                set -a args $arg
            end
        end
        set -q args[1]; or set args $PWD

        set -l lastdir (command superfile path-list --lastdir-file)
        command superfile $args
        if test -f "$lastdir"
            source "$lastdir"
            rm -f -- "$lastdir"
        end
      '';
    };
  };
}
