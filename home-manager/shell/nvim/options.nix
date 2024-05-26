{
  programs.nixvim = {
    options = {
      # tabs & indent
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;

      # line numbers
      number = true;
      relativenumber = true;

      # search settings
      ignorecase = true;
      smartcase = true;

      # looks and feels
      termguicolors = true;
      background = "dark";
      signcolumn = "yes";

      # backspace
      backspace = "indent,eol,start";

      # split windows
      # true -> goes to direction
      # false -> stays where it is
      splitright = true;
      splitbelow = true;

      wrap = false;
      cursorline = true;
      mouse = "a";
    };
    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };
  };
}
