{pkgs, ...}: {
  programs.helix = {
    languages = {
      language = [
        {
          name = "json";
          auto-format = true;
          # rulers = [120];
        }
      ];
      language-server = {
      };
    };
    extraPackages = with pkgs; [
      nodePackages.vscode-json-languageserver
    ];
  };
}
