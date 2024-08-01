{pkgs, ...}: {
  programs.helix = {
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "alejandra";
          # formatter.command = "${pkgs.alejandra}/bin/alejandra";
        }
      ];
    };
    extraPackages = with pkgs; [
      nil
      alejandra
    ];
  };
}
