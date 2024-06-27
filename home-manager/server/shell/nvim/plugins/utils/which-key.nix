{
  programs.nixvim = {
    plugins = {
      which-key = {
        enable = true;
        registrations = {
          "<localLeader>l" = "+vimtex";
        };
      };
    };
  };
}
