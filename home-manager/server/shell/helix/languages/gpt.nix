{pkgs, ...}: {
  programs.helix = {
    languages = {
      # language = [
      #   {
      #     name = "python";
      #     language-servers = ["gpt"];
      #   }
      # ];
      language-server = {
        gpt = {
          command = "helix-gpt";
        };
      };
    };
    extraPackages = with pkgs; [
      helix-gpt
    ];
  };
}
