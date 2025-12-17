{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.ollama.enable {
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
        "gemma3:4b"
        "gemma3:12b"
        "mistral:7b"
        "ministral-3:3b"
        "ministral-3:8b"
        "ministral-3:14b"
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
  };

}
