# Decky Loader as the module sets it up: the service, declarative plugins next
# to store-installed ones, and the CEF flag file in the Steam user's home.
#
# No Gaming Mode here (autoStart is off): Decky loads its plugins at startup
# whether or not Steam is running, and injecting into Steam's UI needs the
# real client, which the VM does not have.
{ testLib }:
{
  name = "steamix-decky-loader";

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ testLib.baseNode ];

      steamix = {
        enable = true;
        user = "alice";
        autoStart = false;
        decky-loader = {
          enable = true;
          package = testLib.steamixPackages.decky-loader;
          plugins = with testLib.steamixPackages.deckyPlugins; [
            hltb-for-deck # frontend only
            protondb-decky # has a Python backend
          ];
        };
      };

      environment.systemPackages = [ pkgs.curl ];

      # Starts alice's user manager at boot, standing in for the login that
      # Gaming Mode would do: the CEF flag is created by her own tmpfiles
      # instance when it starts.
      users.users.alice.linger = true;
    };

  testScript =
    { nodes, ... }:
    let
      home = nodes.machine.users.users.alice.home;
      plugins = "${nodes.machine.steamix.decky-loader.stateDir}/plugins";
    in
    ''
      def decky_log():
          return machine.succeed("journalctl -b -u decky-loader.service --no-pager -o cat")

      def wait_for_log(line):
          machine.wait_until_succeeds(
              f"journalctl -b -u decky-loader.service --no-pager -o cat | grep -qF {line!r}",
              timeout=60,
          )

      machine.start()

      with subtest("the loader runs and serves"):
          machine.wait_for_unit("decky-loader.service")
          machine.wait_for_open_port(1337)
          token = machine.succeed("curl -sf http://127.0.0.1:1337/auth/token").strip()
          assert token, "no auth token from the loader"

      with subtest("declared plugins are linked from the store and load"):
          for name in ["hltb-for-deck", "protondb-decky"]:
              target = machine.succeed(f"readlink ${plugins}/{name}").strip()
              assert target.startswith("/nix/store/"), f"{name} -> {target}"
          wait_for_log("Loaded HLTB for Deck")
          wait_for_log("Loaded ProtonDB Badges")
          log = decky_log()
          assert "Plugin HLTB for Deck is passive" in log, "frontend-only plugin not passive"
          assert "Plugin ProtonDB Badges is passive" not in log, "backend plugin taken as passive"
          assert "Could not load" not in log, log

      with subtest("plugin backends drop to the unprivileged user"):
          machine.wait_until_succeeds("pgrep -u decky", timeout=30)

      with subtest("the CEF debugging flag is in the Steam user's home"):
          # The lingering user manager first: asking it for a unit before it
          # runs is an error rather than a wait.
          machine.wait_for_unit("user@1000.service")
          machine.wait_for_unit("default.target", user="alice")
          machine.succeed("test -f ${home}/.local/share/Steam/.cef-enable-remote-debugging")
          # The directories leading to it have to stay the user's, or a
          # Steam that was never started before cannot create its own files.
          for d in [".local", ".local/share", ".local/share/Steam"]:
              owner = machine.succeed(f"stat -c %U ${home}/{d}").strip()
              assert owner == "alice", f"~/{d} is owned by {owner}, not alice"

      with subtest("a store-installed plugin coexists with declared ones"):
          machine.succeed(
              "install -d -o decky -g decky ${plugins}/store-plugin",
              "echo '{\"name\": \"Store Plugin\", \"author\": \"test\", \"flags\": []}'"
              " > ${plugins}/store-plugin/plugin.json",
          )
          # A declared plugin removed through the UI is only a symlink gone...
          machine.succeed("rm ${plugins}/hltb-for-deck")

      machine.shutdown()
      machine.start()

      with subtest("after a reboot both kinds are back"):
          machine.wait_for_unit("decky-loader.service")
          # ...which the next boot restores: declarative wins.
          machine.succeed("test -L ${plugins}/hltb-for-deck")
          machine.succeed("test -f ${plugins}/store-plugin/plugin.json")
          wait_for_log("Loaded Store Plugin")
          wait_for_log("Loaded HLTB for Deck")
    '';
}
