{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./lichess.nix ];
  options.gaming.chess.enable = lib.mkEnableOption "Enable chess games.";

  config = lib.mkIf config.gaming.chess.enable {
    services.lichess-bot = {
      enable = true;
      package = pkgs.unstable.lichess-bot;
      settings = {
        url = "https://lichess.org/";
        challenge = {
          allow_list = [ "arunoruto" ];
          concurrency = 1;
          sort_by = "best";
          accept_bot = false;
          only_bot = false;
          # Limits (Required to avoid crashing on weird requests)
          max_increment = 180;
          min_increment = 0;
          max_base = 315360000;
          min_base = 0;
          # What you actually play (The "variants" list caused your error)
          variants = [ "standard" ];
          time_controls = [
            "bullet"
            "blitz"
            "rapid"
            "classical"
          ];
          modes = [
            # "rated"
            "casual"
          ];
        };
        # You can even set a default engine path if they share binaries
        engine = {
          protocol = "uci";
          uci_options = {
            Threads = 4;
            Hash = 512;
            UCI_ShowWDL = true;
          };
        };
      };
      profiles = {
        stockfish = {
          tokenSecretName = "tokens/lichess";
          settings = {
            engine = {
              name = "stockfish";
              dir = "${pkgs.stockfish}/bin"; # Nix path handling!
              uci_options.go_commands.movetime = 1000; # Think for 2s
            };
          };
        };
      };
    };
    environment.systemPackages = with pkgs.unstable; [
      stockfish
      lichess-bot
    ];

    sops.secrets."tokens/lichess" = {
      owner = "lichess-bot";
      group = "lichess-bot";
    };
  };
}
