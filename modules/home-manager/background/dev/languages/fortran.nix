{ pkgs, lib, ... }:
{
  programs.dev.languages.fortran = {
    extensions = [ ".f90" ];
    helix.fileTypes = [ "f90" ];
    autoFormat = true;

    formatter = {
      package = pkgs.fprettify;
      command = lib.getExe pkgs.fprettify;
      args = [ "--silent" ];
    };

    helix.languageConfig = {
      scope = "source.f90";
      comment-token = "!";
      indent = {
        tab-width = 3;
        unit = " ";
      };
    };

    packages = with pkgs; [
      fortls
      fprettify
    ];
  };
}
