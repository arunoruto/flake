{
  programs.nixvim = {
    # autoGroups = {
    #   UserLspConfig.clear = true;
    # };
    autoCmd = [
      {
        event = ["BufEnter"];
        pattern = ["*.md"];
        command = "setlocal wrap";
      }
    ];
  };
}
