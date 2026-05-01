{
  config,
  pkgs,
  lib,
  ...
}:
{
  # config = lib.mkIf config.services.ollama.enable {
  config = {
    services.ollama = {
      # package = pkgs.ollama;
      # package = pkgs.unstable.ollama;
      # if config.hosts.nvidia.enable then
      #   pkgs.unstable.ollama-cuda
      # else if config.hosts.amd.enable then
      #   pkgs.unstable.ollama-rocm
      # else
      #   pkgs.unstable.ollama;
      package = lib.mkDefault (
        if config.hosts.nvidia.enable then
          pkgs.ollama-cuda
        else if config.hosts.amd.enable then
          pkgs.ollama-rocm
        else
          pkgs.ollama-vulkan
      );
      host = "0.0.0.0";
      loadModels = [
        "deepseek-r1:14b"
        "embeddinggemma:300m"
        "ministral-3:3b"
        "ministral-3:8b"
        "ministral-3:14b"
        # "gemma3:4b"
        # "gemma3:12b"
        "gemma4:e4b"
        "gemma4:e2b"
      ];
      openFirewall = true;
      # acceleration =
      #   if config.hosts.nvidia.enable then
      #     "cuda"
      #   else if config.hosts.amd.enable then
      #     "rocm"
      #   else
      #     null;
      environmentVariables = {
        OLLAMA_ORIGINS = "moz-extension://*";
      };
    };
    systemd.services = {
      ollama = {
        serviceConfig = {
          # This is the magic bullet for the "JIT session error"
          MemoryDenyWriteExecute = lib.mkForce false;
        };
      };
      ollama-custom-models = {
        description = "Build custom Ollama models with constrained context";
        wantedBy = [ "multi-user.target" ];
        after = [ "ollama.service" ];
        requires = [ "ollama.service" ];

        environment = {
          HOME = "/tmp";
        };

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          # Wait for the Ollama API to be ready
          until ${pkgs.curl}/bin/curl -s http://localhost:11434/api/tags > /dev/null; do
            sleep 1
          done

          # Create E4B 16k
          ${config.services.ollama.package}/bin/ollama create gemma4:e4b-16k -f ${pkgs.writeText "gemma4-e4b-16k.modelfile" ''
            FROM gemma4:e4b
            PARAMETER num_ctx 16384
            SYSTEM "<|think|>"
          ''}

          # Create E2B 32k
          ${config.services.ollama.package}/bin/ollama create gemma4:e2b-32k -f ${pkgs.writeText "gemma4-e2b-32k.modelfile" ''
            FROM gemma4:e2b
            PARAMETER num_ctx 32768
            SYSTEM "<|think|>"
          ''}
        '';
      };
    };
  };

}
