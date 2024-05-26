{
  imports = [
    ./languages
  ];

  programs.helix = {
    enable = true;
    settings = {
      editor = {
        true-color = true;
        line-number = "relative";
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        lsp.display-messages = true;
      };
    };
  };
}
