{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    lazygit = {
      enable = config.programs.git.enable;
      settings = {
        gui = {
          # theme = {
          #   activeBorderColor = [
          #     "#8aadf4"
          #     "bold"
          #   ];
          #   inactiveBorderColor = [ "#a5adcb" ];
          #   optionsTextColor = [ "#8aadf4" ];
          #   selectedLineBgColor = [ "#363a4f" ];
          #   cherryPickedCommitBgColor = [ "#494d64" ];
          #   cherryPickedCommitFgColor = [ "#8aadf4" ];
          #   unstagedChangesColor = [ "#ed8796" ];
          #   defaultFgColor = [ "#cad3f5" ];
          #   searchingActiveBorderColor = [ "#eed49f" ];
          # };
          authorColors = {
            "${config.programs.git.settings.user.name}" = config.lib.stylix.colors.withHashtag.base0C;
            "*" = config.lib.stylix.colors.withHashtag.base0D;
          };
        };
        customCommands = [
          (lib.optionalAttrs (pkgs ? "git-quill") {
            key = "<c-a>";
            description = "Generate AI Commit Message";
            loadingText = "Generating commit message...";
            context = "files";
            prompts = [
              {
                type = "menuFromCommand";
                key = "Provider";
                title = "Select Provider:";
                command = "git-quill --list-providers";
              }
              {
                type = "menuFromCommand";
                key = "Model";
                title = "Select Model (optional):";
                command = "git-quill --list-models {{.Form.Provider}}";
              }
              {
                type = "menu";
                key = "CommitStyle";
                title = "Select commit message style:";
                options = [
                  {
                    name = "Default";
                    description = "Standard conventional commit message.";
                    value = " ";
                  }
                  {
                    name = "Emoji";
                    description = "Add a GitMoji to the commit title.";
                    value = "-e";
                  }
                  {
                    name = "Brief";
                    description = "Generate a short, one-sentence summary.";
                    value = "-b";
                  }
                  {
                    name = "Brief + Emoji";
                    description = "Combine both brief and emoji styles.";
                    value = "-b -e";
                  }
                ];
              }
            ];
            # command = ''
            #   git-quill -p {{.Form.Provider}} \
            #     {{if and .Form.Model (ne .Form.Model "(default)") }} -m {{.Form.Model | quote}}{{end}} \
            #     {{.Form.CommitStyle}} \
            #     -o .git/LAZYGIT_PENDING_COMMIT
            # '';
            command = ''
              git-quill commit \
                -p {{.Form.Provider}} \
                -m '{{.Form.Model}}' \
                {{.Form.CommitStyle}} > .git/LAZYGIT_PENDING_COMMIT
            '';
          })
        ];
      };
    };
  };
}
