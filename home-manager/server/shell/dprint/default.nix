{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      dprint
    ];

    file.".config/dprint.jsonc".source = ./dprint.jsonc;
  };
}
