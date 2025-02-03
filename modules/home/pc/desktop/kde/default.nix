{
  inputs,
  config,
  lib,
  ...
}:
let
  available = inputs ? "plasma-manager";
in
{
  imports = lib.optionals available [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  config = lib.mkIf available {
    programs = lib.optionalAttrs (config.programs ? "plasma") {
      plasma = {
        enable = true;

        #
        # Some high-level settings:
        #
        workspace = {
          clickItemTo = "select";
          # lookAndFeel = "org.kde.breezedark.desktop";
          # cursor.theme = "Bibata-Modern-Ice";
          # iconTheme = "Papirus-Dark";
          # wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
        };

        hotkeys.commands."launch-wezterm" = {
          name = "Launch WezTerm";
          key = "Meta+Enter";
          command = "wezterm";
        };

        panels = [
          # Windows-like panel at the bottom
          # {
          #   location = "bottom";
          #   widgets = [
          #     "org.kde.plasma.kickoff"
          #     "org.kde.plasma.icontasks"
          #     "org.kde.plasma.marginsseparator"
          #     "org.kde.plasma.systemtray"
          #     "org.kde.plasma.digitalclock"
          #   ];
          # }

          # Global menu at the top
          # {
          #   location = "top";
          #   height = 26;
          #   widgets = [
          #     "org.kde.plasma.appmenu"
          #   ];
          # }
        ];

        #
        # Some mid-level settings:
        #
        shortcuts = {
          ksmserver = {
            "Lock Session" = [
              "Screensaver"
              "Meta+Ctrl+Alt+L"
            ];
          };

          kwin = {
            "Expose" = "Meta+,";
            "Switch Window Down" = "Meta+J";
            "Switch Window Left" = "Meta+H";
            "Switch Window Right" = "Meta+L";
            "Switch Window Up" = "Meta+K";
          };
        };

        #
        # Some low-level settings:
        #
        configFile = {
          "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
          "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
          "kwinrc"."Desktops"."Number" = {
            value = 10;
            # Forces kde to not change this value (even through the settings app).
            immutable = true;
          };
        };
      };
    };
    # qt = {
    #   enable = true;
    # };
  };
}
