# SteamOS Manager finds its own data: the platform file and the per-device
# configs it ships, which upstream reads from /usr/share/steamos-manager and
# the package installs into its store path.
#
# The device configs are what turns on TDP, GPU and performance-profile
# controls for handhelds. They are matched by DMI, so one machine here
# presents a ROG Ally's DMI identity (QEMU's SMBIOS tables) and has to be
# recognised as one, and the other keeps QEMU's own identity and has to come
# out as "unknown" without an error, the way a desktop PC does.
{ testLib }:
let
  manager =
    { ... }:
    {
      imports = [ testLib.baseNode ];

      steamix = {
        enable = true;
        user = "alice";
        # No login path needed: the daemons are what is under test. The user
        # daemon is D-Bus activated on alice's session bus.
        autoStart = false;
        manager = {
          enable = true;
          package = testLib.steamixPackages.steamos-manager;
        };
      };

      # Starts alice's user manager, and with it her session bus, at boot.
      users.users.alice.linger = true;
    };
in
{
  name = "steamix-steamos-manager";

  nodes = {
    ally =
      { ... }:
      {
        imports = [ manager ];
        # sys_vendor comes from SMBIOS type 1, board_name from type 2; both
        # are what data/devices/rog-ally-series.toml matches on. Quoted
        # because the options are pasted into the VM's start script.
        virtualisation.qemu.options = [
          "-smbios 'type=1,manufacturer=ASUSTeK COMPUTER INC.,product=ROG Ally RC71L'"
          "-smbios 'type=2,manufacturer=ASUSTeK COMPUTER INC.,product=RC71L'"
        ];
      };

    desktop = manager;
  };

  testScript = ''
    import shlex

    def as_alice(cmd):
        env = "XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        return f"su alice -s /bin/sh -c {shlex.quote(env + ' ' + cmd)}"

    device_model = as_alice(
        "busctl --user get-property com.steampowered.SteamOSManager1"
        " /com/steampowered/SteamOSManager1"
        " com.steampowered.SteamOSManager1.Manager2 DeviceModel"
    )

    start_all()
    for m in [ally, desktop]:
        m.wait_for_unit("steamos-manager.service")
        m.wait_for_unit("default.target", user="alice")

    with subtest("the VM really presents a ROG Ally's DMI identity"):
        assert ally.succeed("cat /sys/class/dmi/id/sys_vendor").strip() == "ASUSTeK COMPUTER INC."
        assert ally.succeed("cat /sys/class/dmi/id/board_name").strip() == "RC71L"

    with subtest("a matching handheld is recognised from the shipped device configs"):
        model = ally.wait_until_succeeds(device_model, timeout=60)
        assert '"rog_ally" "RC71L"' in model, model

    with subtest("anything else is unknown, not an error"):
        model = desktop.wait_until_succeeds(device_model, timeout=60)
        assert '"unknown" "unknown"' in model, model

    with subtest("Valve's platform file offers nothing a PC cannot back"):
        # Every entry in it names a Deck script or unit, and each interface
        # is only published when that exists, which on NixOS it never does.
        # Loading the file must not put Deck-only controls in Steam's menus.
        interfaces = desktop.succeed(
            as_alice(
                "busctl --user introspect com.steampowered.SteamOSManager1"
                " /com/steampowered/SteamOSManager1"
            )
        )
        for name in ["FactoryReset1", "FanControl1", "UpdateBios1", "UpdateDock1", "Storage1"]:
            assert f"com.steampowered.SteamOSManager1.{name}" not in interfaces, name

    with subtest("the platform file and device configs are found"):
        for m in [ally, desktop]:
            journal = m.succeed("journalctl -b --no-pager -o cat")
            for line in [
                "Failed to scan device configs",
                "Failed to read /usr/share/steamos-manager/platform.toml",
            ]:
                assert line not in journal, f"{m.name}: {line}"
  '';
}
