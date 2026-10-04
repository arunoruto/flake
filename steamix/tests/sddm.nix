# The SteamOS-shaped login path end to end: SDDM autologin into Gaming Mode,
# with switching done by SteamOS Manager the way Valve's image does it. Steam
# asks the manager to switch (here through `steamos-session-select`, which
# delegates to `steamosctl` on this path); the manager writes SDDM's
# temporary autologin drop-in and stops graphical-session.target; the
# session's stand-in unit shuts Steam down; SDDM's relogin starts whatever
# the drop-in named.
#
# Steam, gamescope and the desktop are the stand-ins from ./lib.nix. SDDM,
# PAM, logind, SteamOS Manager (system and user daemons), the session script
# and the switcher are real.
{ testLib }:
{
  name = "steamix-sddm";

  nodes.machine =
    { ... }:
    {
      imports = [ testLib.baseNode ];

      services.displayManager.sessionPackages = [ testLib.desktopSession ];

      steamix = {
        enable = true;
        user = "alice";
        desktopSession = "fake-desktop";
        loginManager = "sddm";
        manager.package = testLib.steamixPackages.steamos-manager;
      };
    };

  testScript =
    { nodes, ... }:
    let
      dir = testLib.stateDir;
      home = nodes.machine.users.users.alice.home;
      uid = toString nodes.machine.users.users.alice.uid;
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

      def as_alice(cmd):
          # alice's session bus, the one Steam and steamosctl talk to.
          env = "XDG_RUNTIME_DIR=/run/user/${uid} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus"
          return f"su alice -s /bin/sh -c {shlex.quote(env + ' ' + cmd)}"

      gamescope = "pgrep -u alice -x gamescope"

      machine.start()
      machine.wait_for_unit("display-manager.service")

      with subtest("SDDM logs straight into Gaming Mode"):
          wait_for_starts("steam", 1)
          machine.wait_until_succeeds(gamescope, timeout=60)
          # Registered under Valve's name too: the manager asks for it by name.
          argv = cat("${dir}/gamescope-args").splitlines()
          assert "--steam" in argv, argv
          session = machine.succeed("loginctl list-sessions --no-legend")
          assert "alice" in session, session

      with subtest("SteamOS Manager is up and owns session switching"):
          machine.wait_for_unit("steamos-manager.service")
          machine.wait_for_unit("steamos-manager.service", user="alice")
          # Published only when it finds the holo.conf marker.
          machine.wait_until_succeeds(
              as_alice(
                  "busctl --user introspect com.steampowered.SteamOSManager1"
                  " /com/steampowered/SteamOSManager1"
                  " | grep -q com.steampowered.SteamOSManager1.SessionManagement1"
              ),
              timeout=60,
          )
          # The stand-in that lets the manager see, and end, Gaming Mode.
          machine.wait_until_succeeds(
              "systemctl --user -M alice@ is-active gamescope-session.service", timeout=60
          )
          # "Switch to Desktop" means the configured session, not plasma.
          machine.wait_until_succeeds(
              "grep -q 'fake-desktop.desktop' ${home}/.config/steamos-manager/state.toml",
              timeout=60,
          )

      with subtest("Switch to Desktop goes through the manager"):
          machine.succeed("echo plasma > ${dir}/steam-cmd")
          wait_for_starts("desktop", 1)
          machine.wait_until_fails(gamescope, timeout=60)
          # Steam was asked to quit by the stand-in unit's ExecStop, not killed.
          assert "shutdown requested" in cat("${dir}/steam.log"), cat("${dir}/steam.log")

      with subtest("the desktop is a real Wayland user session"):
          env = env_of("${dir}/desktop-env")
          assert env.get("XDG_SESSION_TYPE") == "wayland", env.get("XDG_SESSION_TYPE")
          session = cat("${dir}/desktop-session")
          assert "Type=wayland" in session, session
          assert "Class=user" in session, session
          machine.wait_until_succeeds(
              "systemctl --user -M alice@ list-units 'fake-desktop-shell-*'"
              " --state=active --no-legend | grep -q .",
              timeout=30,
          )

      with subtest("Return to Gaming Mode goes through the manager"):
          machine.succeed("touch ${dir}/desktop-cmd")
          wait_for_starts("steam", 2)
          machine.wait_until_succeeds(gamescope, timeout=60)
          assert starts("desktop") == 1, "desktop was started again"

      with subtest("a crashed session falls back to Gaming Mode"):
          machine.succeed("pkill -KILL -u alice -x gamescope")
          wait_for_starts("steam", 3)
          machine.wait_until_succeeds(gamescope, timeout=60)
          assert starts("desktop") == 1, "a crash landed in the desktop"
          # ...and stays there. A session that comes back only to be shut
          # down again is a restart loop, which on the SDDM path a race
          # between stand-in units once caused, twice a second.
          machine.sleep(10)
          assert starts("steam") == 3, f"Gaming Mode restarted {starts('steam') - 3} more times"
          machine.succeed(gamescope)

      with subtest("a stale switch cannot pin the machine after a reboot"):
          # The vendor failsafe: a temporary session left behind is cleared
          # when the display manager starts, so boot always lands in Gaming
          # Mode.
          machine.succeed(
              "printf '[Autologin]\\nSession=fake-desktop.desktop\\n'"
              " > /etc/sddm.conf.d/zzt-holo-temp-login.conf"
          )

      machine.shutdown()
      machine.start()
      machine.wait_for_unit("display-manager.service")

      with subtest("after a reboot it is Gaming Mode again"):
          wait_for_starts("steam", 4)
          machine.wait_until_succeeds(gamescope, timeout=60)
          assert starts("desktop") == 1, "the stale temporary session was honoured"
          machine.sleep(5)
          assert starts("steam") == 4, "Gaming Mode restarted after the reboot"
    '';
}
