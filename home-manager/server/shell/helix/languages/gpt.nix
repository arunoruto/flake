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
          args = ["--handler" "copilot"];
          # args = ["--handler" "openai" "--openaiKey"];
        };
      };
    };
    extraPackages = with pkgs; [
      helix-gpt
    ];
  };
}
