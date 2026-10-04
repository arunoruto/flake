# The default login path end to end: boot into Gaming Mode through the greetd
# loop, "Switch to Desktop", "Return to Gaming Mode", and recover from a
# crashed session, with the real greetd, PAM stack, logind, launcher, session
# script and switcher. Steam, gamescope and the desktop are stand-ins (see
# ./lib.nix for why), so what is checked about Gaming Mode is what the module
# controls: the command line and environment it hands them.
{ testLib }:
{
  name = "steamix-greetd";

  nodes.machine =
    { ... }:
    {
      imports = [ testLib.baseNode ];

      services.displayManager.sessionPackages = [ testLib.desktopSession ];

      steamix = {
        enable = true;
        user = "alice";
        desktopSession = "fake-desktop";
        # Both must reach the session untouched.
        gamescope = {
          args = [ "--steamix-test-arg" ];
          env.STEAMIX_TEST_ENV = "from the option";
        };
      };
    };

  testScript =
    { nodes, ... }:
    let
      dir = testLib.stateDir;
      home = nodes.machine.users.users.alice.home;
    in
    ''
      import shlex

      def cat(path):
          return machine.succeed(f"cat {shlex.quote(path)}")

      def starts(what):
          return int(machine.succeed(f"cat ${dir}/{what}-starts 2>/dev/null || echo 0").strip())

      def wait_for_starts(what, n):
          machine.wait_until_succeeds(
              f"test \"$(cat ${dir}/{what}-starts 2>/dev/null)\" -ge {n}", timeout=180
          )

      def env_of(path):
          return dict(
              line.split("=", 1) for line in cat(path).splitlines() if "=" in line
          )

      gamescope = "pgrep -u alice -x 'gamescope(-wl)?'"

      machine.start()
      machine.wait_for_unit("greetd.service")

      with subtest("boots straight into Gaming Mode"):
          wait_for_starts("steam", 1)
          machine.wait_until_succeeds(gamescope, timeout=60)

      with subtest("gamescope gets the command line the options describe"):
          argv = cat("${dir}/gamescope-args").splitlines()
          assert "--" in argv, argv
          sep = argv.index("--")
          gs, child = argv[:sep], argv[sep + 1 :]
          for flag in ["--steam", "--hdr-enabled", "--adaptive-sync", "--mangoapp"]:
              assert flag in gs, f"gamescope not started with {flag}: {gs}"
          assert gs[gs.index("--xwayland-count") + 1] == "2", gs
          for flag in ["--immediate-flips", "--rt"]:
              assert flag not in gs, f"{flag} passed while its option is off: {gs}"
          # steamix.gamescope.args is appended after the module's own.
          assert gs[-1] == "--steamix-test-arg", gs
          assert child[0].endswith("/bin/steam"), child

      with subtest("Steam is started the way Valve's session starts it"):
          args = cat("${dir}/steam-args").split()
          for flag in ["-gamepadui", "-steamos3", "-steampal", "-steamdeck"]:
              assert flag in args, f"steam was not started with {flag}: {args}"

          env = env_of("${dir}/steam-env")
          expected = {
              "XDG_SESSION_TYPE": "x11",
              "STEAM_MULTIPLE_XWAYLANDS": "1",
              "ENABLE_GAMESCOPE_WSI": "1",
              "STEAM_GAMESCOPE_HDR_SUPPORTED": "1",
              "STEAM_GAMESCOPE_VRR_SUPPORTED": "1",
              "STEAM_USE_MANGOAPP": "1",
              "STEAMIX_SESSION_JOURNAL": "1",
              "STEAMIX_TEST_ENV": "from the option",
          }
          for var, value in expected.items():
              assert env.get(var) == value, f"{var}={env.get(var)!r}, expected {value!r}"
          assert not any("TEARING" in var for var in env), "tearing advertised while disabled"
          # The limiter file and the mode save file are created per session.
          assert env.get("GAMESCOPE_MODE_SAVE_FILE", "").endswith("/gamescope/modes.cfg"), env
          machine.succeed(f"test -e {shlex.quote(env['GAMESCOPE_MODE_SAVE_FILE'])}")
          machine.succeed(f"test -e {shlex.quote(env['GAMESCOPE_LIMITER_FILE'])}")

      with subtest("the Steamix binary cache is configured, next to cache.nixos.org"):
          conf = machine.succeed("cat /etc/nix/nix.conf")
          substituters = next(l for l in conf.splitlines() if l.startswith("substituters ="))
          keys = next(l for l in conf.splitlines() if l.startswith("trusted-public-keys ="))
          assert "https://steamix.cachix.org" in substituters, substituters
          assert "https://cache.nixos.org" in substituters, substituters
          assert "steamix.cachix.org-1:" in keys, keys

      with subtest("the session logs to the journal"):
          machine.wait_until_succeeds(
              "journalctl -t steamix-session --no-pager | grep -q 'gamescope stub: running'"
          )

      with subtest("the performance overlay presets are sized and in place"):
          presets = cat("${home}/.config/MangoHud/steamix-presets.conf")
          assert "@fontScale@" not in presets and "@denseScale@" not in presets, presets
          assert "font_scale=" in presets, presets
          machine.succeed("test -s ${home}/.local/share/Steam/config/mangohud.conf")

      with subtest("Switch to Desktop lands in the configured desktop session"):
          machine.succeed("echo plasma > ${dir}/steam-cmd")
          wait_for_starts("desktop", 1)
          machine.wait_until_fails(gamescope, timeout=60)
          assert "shutdown requested" in cat("${dir}/steam.log"), "Steam was not shut down cleanly"
          # The selection is consumed: the next cycle falls back to Gaming Mode.
          machine.fail("test -e ${home}/.local/state/steamos-session-select")

      with subtest("the desktop gets a real Wayland user session"):
          env = env_of("${dir}/desktop-env")
          assert env.get("XDG_SESSION_TYPE") == "wayland", env.get("XDG_SESSION_TYPE")
          assert env.get("XDG_SESSION_DESKTOP") == "fake-desktop", env.get("XDG_SESSION_DESKTOP")
          assert env.get("XDG_CURRENT_DESKTOP") == "FakeDE", env.get("XDG_CURRENT_DESKTOP")
          # The pam_env rule: logind must create the session as type=wayland,
          # class=user, or GNOME and mutter refuse to start on it.
          session = cat("${dir}/desktop-session")
          assert "Type=wayland" in session, session
          assert "Class=user" in session, session
          # ...and the identity reaches the systemd user manager, where
          # gnome-shell's unit asserts on it.
          user_env = machine.succeed("systemctl --user -M alice@ show-environment")
          assert "XDG_SESSION_TYPE=wayland" in user_env, user_env
          machine.succeed(
              "test -e /run/current-system/sw/share/applications/return-to-gaming-mode.desktop"
          )

      with subtest("Return to Gaming Mode"):
          machine.succeed("touch ${dir}/desktop-cmd")
          wait_for_starts("steam", 2)
          machine.wait_until_succeeds(gamescope, timeout=60)
          assert starts("desktop") == 1, "desktop was started again"

      with subtest("a crashed session falls back to Gaming Mode"):
          machine.succeed("pkill -KILL -u alice -x 'gamescope(-wl)?'")
          wait_for_starts("steam", 3)
          machine.wait_until_succeeds(gamescope, timeout=60)
          assert starts("desktop") == 1, "a crash landed in the desktop"
          # ...and stays there. A session that comes back only to be shut
          # down again is a restart loop, which on the SDDM path a race
          # between stand-in units once caused, twice a second.
          machine.sleep(10)
          assert starts("steam") == 3, f"Gaming Mode restarted {starts('steam') - 3} more times"
          machine.succeed(gamescope)
    '';
}
