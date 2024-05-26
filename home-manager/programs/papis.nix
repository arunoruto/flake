{
  programs.papis = {
    enable = true;
    settings = {
      editor = "nvim";
      file-editor = "yazi";
      add-confirm = true;
      add-edit = true;
      add-open = true;
    };
    libraries = {
      research = {
        isDefault = true;
        settings = {
          dir = "~/Documents/papers";
        };
      };
    };
  };
}
