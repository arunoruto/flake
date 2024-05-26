{
  programs.nixvim = {
    plugins = {
      hardtime = {
        enable = true;
        enabled = true;
        maxCount = 1000;
        maxTime = 10000;
      };
    };
  };
}
