{ config, ... }:
{
  programs.papis = {
    enable = config.hosts.desktop.enable;
    settings = {
      editor = "hx";
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
