# Plasma's home config, following services.desktopManager.plasma6.enable like
# the other sessions. Written through plasma-manager, which edits the KDE rc
# files at activation instead of owning them, so changes made in System
# Settings survive until the next switch. Mirrors ../gnome/dconf.nix where
# Plasma has an equivalent. Colours, fonts, cursor and wallpaper come from
# Stylix's KDE target (modules/home-manager/theming/stylix).
{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? null,
  ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  hasPlasma = isLinux && (osConfig != null) && osConfig.services.desktopManager.plasma6.enable;

  # GNOME's fixed 9 workspaces.
  desktops = lib.range 1 9;
  # What Shift+<digit> types on a US-style layout. KWin on Wayland can
  # match a Shift+digit shortcut by the shifted symbol instead of the digit,
  # so the move-window bindings carry both spellings.
  # ponytail: hardcoded US/de(us) symbols, derive from the XKB layout if a host uses another one
  shifted = lib.stringToCharacters "!@#$%^&*(";
  forDesktops = f: lib.listToAttrs (map f desktops);

  # KZones layouts, replacing GNOME's Tactile. Its grid there is 4 columns
  # weighted 3:2:2:3 over 2 rows, used as "left three columns" and "right
  # column": 70% and 30% of the screen. Zones are in percent; zone N takes
  # Meta+Ctrl+N.
  kzonesLayouts = [
    {
      name = "Main + side";
      padding = 0;
      zones = [
        {
          x = 0;
          y = 0;
          width = 70;
          height = 100;
        }
        {
          x = 70;
          y = 0;
          width = 30;
          height = 100;
        }
      ];
    }
  ];
in
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  config = lib.mkIf hasPlasma {
    home.packages = with pkgs; [
      kdePackages.kzones
      # Tray toggle for Tailscale, standing in for GNOME's tailscale-qs.
      ktailctl
    ];

    # A Plasma session started from GDM never runs a login shell, so it
    # misses home-manager's session variables -- including the
    # XDG_CONFIG_DIRS entry carrying Stylix's KDE config, whose switch that
    # stops KDE from rewriting ~/.gtkrc-2.0 and gtk.css (which home-manager
    # owns). startplasma sources these scripts before starting the session
    # services.
    xdg.configFile."plasma-workspace/env/hm-session-vars.sh".text = ''
      . "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"
    '';

    # That switch only stops KDE's GTK sync (kde-gtk-config, a required
    # Plasma package) from autoloading. It still loads on demand whenever a
    # look-and-feel is applied, which Stylix does at every Plasma login, and
    # rewrites the GTK files below. Let home-manager take them back on
    # activation instead of failing on the stale backup.
    home.file =
      lib.genAttrs
        [
          config.gtk.gtk2.configLocation
          "${config.xdg.configHome}/gtk-3.0/gtk.css"
          "${config.xdg.configHome}/gtk-3.0/settings.ini"
          "${config.xdg.configHome}/gtk-4.0/gtk.css"
          "${config.xdg.configHome}/gtk-4.0/settings.ini"
        ]
        (_: {
          # The gtk and xdg modules pin it to false.
          force = lib.mkForce true;
        });

    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select";
        iconTheme = lib.mkIf config.theming.icons.enable "candy-icons";
      };

      kwin = {
        virtualDesktops = {
          number = builtins.length desktops;
          rows = 1;
        };
        # GNOME's button-layout "appmenu:minimize,close".
        titlebarButtons = {
          left = [ "more-window-actions" ];
          right = [
            "minimize"
            "close"
          ];
        };
      };

      # GNOME's layout: a permanent top bar (workspaces, clock, status) and a
      # dock that only shows up when needed. plasma-manager rebuilds the
      # panels whenever this changes, so edits made by hand don't survive.
      panels = [
        {
          location = "top";
          height = 32;
          widgets = [
            { pager = { }; }
            "org.kde.plasma.panelspacer"
            { digitalClock = { }; }
            "org.kde.plasma.panelspacer"
            { systemTray = { }; }
          ];
        }
        {
          location = "bottom";
          floating = true;
          lengthMode = "fit";
          hiding = "autohide";
          widgets = [
            { kickoff = { }; }
            {
              # GNOME's favorite-apps.
              iconTasks.launchers = [
                "preferred://browser"
                "applications:thunderbird.desktop"
                "preferred://filemanager"
                "applications:com.mitchellh.ghostty.desktop"
              ];
            }
          ];
        }
      ];

      hotkeys.commands.terminal = {
        name = "Launch terminal";
        key = "Meta+Return";
        command = config.terminals.main;
      };

      shortcuts = {
        kwin =
          forDesktops (n: lib.nameValuePair "Switch to Desktop ${toString n}" "Meta+${toString n}")
          // forDesktops (
            n:
            lib.nameValuePair "Window to Desktop ${toString n}" [
              "Meta+Shift+${toString n}"
              "Meta+${builtins.elemAt shifted (n - 1)}"
            ]
          )
          // {
            "Window Close" = [
              "Alt+F4"
              "Meta+Shift+Q"
            ];
            "Expose" = "Meta+,";
            "Switch Window Down" = "Meta+J";
            "Switch Window Left" = "Meta+H";
            "Switch Window Right" = "Meta+L";
            "Switch Window Up" = "Meta+K";
          }
          // forDesktops (
            n: lib.nameValuePair "KZones: Move active window to zone ${toString n}" "Meta+Ctrl+${toString n}"
          );
        # Meta+L focuses the window to the right.
        ksmserver."Lock Session" = [
          "Screensaver"
          "Meta+Escape"
        ];
        # Meta+<digit> activates task manager entries by default (GNOME's
        # switch-to-application-N, cleared there too).
        plasmashell = forDesktops (n: lib.nameValuePair "activate task manager entry ${toString n}" [ ]);
        # GNOME's emoji picker binding, on Plasma's own picker.
        "org.kde.plasma.emojier.desktop"._launch = [
          "Meta+."
          "Ctrl+<"
        ];
      };

      # GNOME on a non-laptop never dims, blanks or locks on idle
      # (idle-delay 0, idle-dim false).
      powerdevil.AC = lib.mkIf (!config.hosts.laptop.enable) {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        turnOffDisplay.idleTimeout = "never";
      };
      kscreenlocker.autoLock = lib.mkIf (!config.hosts.laptop.enable) false;

      configFile = {
        baloofilerc."Basic Settings"."Indexing-Enabled" = false;
        # "Open terminal here" in Dolphin; nautilus-open-any-terminal's
        # counterpart.
        kdeglobals = {
          General.TerminalApplication = config.terminals.main;
          # No event sounds (device plugged in, notifications, errors).
          Sounds.Enable = false;
        };
        # No click when changing the volume.
        plasmaparc.General.AudioFeedback = false;
        kwinrc = {
          # Meta alone opens the Overview (GNOME's Activities) rather than the
          # launcher; the launcher stays on the dock and Alt+F1.
          ModifierOnlyShortcuts.Meta = "org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,Overview";
          Plugins = {
            kzonesEnabled = true;
            # GNOME's workspaces-only-on-primary (kdeplasma-addons, Plasma 6.6+).
            virtualdesktopsonlyonprimaryEnabled = true;
          };
          Script-kzones.layoutsJson = builtins.toJSON kzonesLayouts;
        };
      };
    };
  };
}
