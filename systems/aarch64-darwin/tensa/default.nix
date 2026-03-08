{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{
  # Platform and nixpkgs configuration
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays = [
      self.overlays.additions
      self.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  # System packages
  environment.systemPackages =
    (with pkgs; [
      direnv
      helix
      nh
      git-quill
      # rnote
    ])
    ++ (with pkgs.unstable; [
      # devenv
    ])
    ++ [
      inputs.devenv.packages.aarch64-darwin.devenv
    ];

  # Networking
  # services.tailscale.enable = true;
  # networking.hostName = "tensa";

  # Ollama AI service
  # services.ollama = {
  #   enable = true;
  #   package = pkgs.unstable.ollama;
  #   host = "127.0.0.1";
  #   port = 11434;
  #   # models = "/path/to/ollama/models";  # Optional: custom models directory
  #   # environmentVariables = {
  #   #   OLLAMA_LLM_LIBRARY = "cpu";  # Force CPU mode
  #   # };
  # };

  # Primary user configuration (shared between NixOS and Darwin)
  users.primaryUser = "mirza";

  # Stylix theming configuration
  stylix = {
    image = ../../../modules/home-manager/theming/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";
  };

  # Darwin-specific modules configuration
  homebrew = {
    enable = true;
    user = "mirza";
    casks = [
      "caffeine"
      "notchnook"
      "telegram"
      "rnote"
      "visual-studio-code"
      "zed"
      "zoom"
    ];
  };

  # security.touchid.enable = true;

  # system = {
  #   defaults.enable = true;
  #   nix.enable = true;
  # };

  # system.activationScripts.applications.text =
  #   let
  #     env = pkgs.buildEnv {
  #       name = "system-applications";
  #       paths = config.environment.systemPackages;
  #       pathsToLink = [ "/Applications" ];
  #     };
  #   in
  #   pkgs.lib.mkForce ''
  #     # Set up applications.
  #     echo "setting up /Applications..." >&2
  #     rm -rf /Applications/Nix\ Apps
  #     mkdir -p /Applications/Nix\ Apps
  #     find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  #     while read -r src; do
  #       app_name=$(basename "$src")
  #       echo "copying $src" >&2
  #       ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  #     done
  #   '';

  # State version
  system.stateVersion = 6;
}
