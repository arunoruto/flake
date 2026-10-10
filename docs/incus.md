# Incus

[Incus](https://linuxcontainers.org/incus/) runs system containers and VMs. The
module is kept in the tree as a ready-to-use mechanism, but **no host enables it
right now** — `sado` was the only one, and it was switched off in 2026-10 when
Home Assistant moved to a dedicated device. This page records the setup so the
infrastructure can be rebuilt without digging through git history.

## Module Location

- `modules/nixos/services/virtualization/incus.nix` — our wrapper, gated on
  `virtualisation.incus.enable`
- Imported from `modules/nixos/services/virtualization/default.nix`
- `modules/nixos/users/mk-user.nix` adds the `incus-admin` group to admin users,
  but only while `virtualisation.incus.enable` is true

## What Enabling It Pulls In

Setting `virtualisation.incus.enable = true;` is the only switch a host needs.
The wrapper then configures:

- `virtualisation.libvirtd.enable = true` — so the host also gains the libvirt
  stack, qemu, OVMF and friends (roughly 1.5 GiB of closure)
- `networking.nftables.enable = true` — incus wants the nftables backend, which
  **replaces the iptables firewall backend** for the whole host
- `ui.enable = true` — the web UI on `https://<host>:8443`
- a preseeded NAT bridge `incusbr0` on `10.42.69.1/24` with DHCP and NAT
- a preseeded ZFS storage pool `zfs-incus` backed by the `flash/incus` dataset
  (incus creates the dataset itself; the pool is named in `preseed.storage_pools`)
- `networking.networkmanager.unmanaged` entries for `incusbr*`, `mac*` and
  `tap*`, so NetworkManager keeps its hands off instance interfaces

Hosts add their own `preseed.profiles` on top — that is where disks, NICs and
USB passthrough live.

## Worked Example: Home Assistant OS on `sado`

`sado` ran Home Assistant OS as an incus **VM** (not a container), bridged onto
the LAN so the router handed it its own address, with the Zigbee coordinators and
both bluetooth radios passed through. The instance looked like this:

```console
$ incus list
┌───────┬─────────┬──────┬──────┬─────────────────┬───────────┐
│ NAME  │  STATE  │ IPV4 │ IPV6 │      TYPE       │ SNAPSHOTS │
├───────┼─────────┼──────┼──────┼─────────────────┼───────────┤
│ HA-OS │ STOPPED │      │      │ VIRTUAL-MACHINE │ 0         │
└───────┴─────────┴──────┴──────┴─────────────────┴───────────┘
```

It occupied roughly 39 GiB on the pool — a `flash/incus/virtual-machines/HA-OS`
filesystem for instance metadata plus a `…/HA-OS.block` zvol for the disk.

### Host prerequisites

The profile below depends on three things being in place first:

1. **A ZFS pool with room for the dataset.** `flash` on `sado`; the preseed's
   `source = "flash/incus"` dataset is created by incus on first start.
2. **A LAN bridge.** `sado` bridges both onboard NICs so instances sit on the
   house network instead of behind incus' NAT:

   ```nix
   networking = {
     bridges.br0 = {
       interfaces = [ "enp1s0" "enp2s0" ];
       rstp = true;
     };
     firewall.trustedInterfaces = [ "br0" ];
     interfaces = {
       br0.useDHCP = true;
     }
     // lib.genAttrs config.networking.bridges.br0.interfaces (name: {
       useDHCP = false;
     });
   };
   ```

3. **Wifi pushed below the bridge in the routing table.** This one cost real
   debugging time: `wlo1` and `br0` both sit on the LAN subnet, and
   NetworkManager gives wifi a route metric of 600, which beats the 1009 dhcpcd
   assigns `br0`. The host then answered its own bridge members out over the
   wifi — an asymmetric path the AP does not hairpin, so host ↔ VM traffic died.
   The fix, still in `sado`'s config because it applies to anything on the
   bridge:

   ```nix
   networking.networkmanager.settings."connection-wifi-lowprio" = {
     match-device = "type:wifi";
     "ipv4.route-metric" = 2000;
     "ipv6.route-metric" = 2000;
   };
   ```

### The profile

```nix
virtualisation.incus = {
  enable = true;
  preseed.profiles = [
    {
      name = "default";
      devices = {
        # Bridged onto br0 rather than incusbr0: the instance gets a LAN
        # address from the router, so it is reachable like any other device.
        eth0 = {
          name = "eth0";
          type = "nic";
          nictype = "bridged";
          parent = "br0";
        };
        root = {
          path = "/";
          pool = "zfs-incus";
          type = "disk";
        };
        # USB passthrough, all required = false so the instance still starts
        # when a dongle is unplugged.
        slzb-mr3 = {
          vendorid = "10c4";
          productid = "ea60";
          type = "usb";
          required = false;
        };
        slzb-ultima3 = {
          vendorid = "303a";
          productid = "4002";
          type = "usb";
          required = false;
        };
        bt-internal = {
          vendorid = "8087";
          productid = "0026";
          type = "usb";
          required = false;
        };
        bt-external = {
          vendorid = "0b05";
          productid = "190e";
          type = "usb";
          required = false;
        };
      };
    }
  ];
};
```

The USB IDs, for when a replacement dongle needs identifying with `lsusb`:

| Device             | Vendor:Product |
| ------------------ | -------------- |
| SMLIGHT SLZB-MR3   | `10c4:ea60`    |
| SMLIGHT SLZB-Ultima3 | `303a:4002`  |
| Internal bluetooth | `8087:0026`    |
| ASUS USB bluetooth | `0b05:190e`    |

A caveat if the hardware moves: `vendorid`/`productid` matches every device with
those IDs, and `10c4:ea60` is the generic CP210x UART — any other CP210x adapter
on the host would be grabbed too.

### Zigbee2MQTT

Zigbee2MQTT and the MQTT broker ran *inside* the HA-OS guest, which is why the
coordinators are passed through to it. The flake's own
`modules/nixos/services/home-assistant/` modules (home-assistant, mosquitto,
zigbee2mqtt, and the `hass-ingress` custom component) were never enabled on
`sado` — they are the alternative, bare-metal way to run the same stack, and
`shinji` carries a disabled example.

## Operating It

```sh
incus list                      # instances
incus launch images:debian/13 c1   # container from the image server
incus exec c1 -- bash           # shell inside an instance
incus profile show default      # what the preseed produced
incus storage list              # pools
```

The web UI is on `https://<host>:8443`. Admin users are in `incus-admin`, so
`incus` works without sudo for them after a re-login.

Getting a Home Assistant OS image in is the one step the preseed cannot do: HA
publishes a qcow2 release image which has to be imported as a VM instance rather
than launched from the image server.

## Tearing It Down

Order matters — the `incus` CLI disappears with the switch, so instances and the
pool go first:

```sh
incus delete <instance>              # add --force if it is running
incus profile device remove default root   # the profile pins the pool
incus storage delete zfs-incus
just switch                          # with the host's incus.enable gone
sudo zfs list -r flash/incus         # expect: dataset does not exist
sudo zfs destroy -r flash/incus      # only if the pool delete left it behind
sudo rm -rf /var/lib/incus
```

Two leftovers survive the switch: `/var/log/incus`, and the `incusbr0` link,
which stays in the kernel with no daemon to own it until
`sudo ip link delete incusbr0` or the next reboot. Disabling the module also
hands the firewall back to the iptables backend, so expect `nftables.service` to
be replaced by `firewall.service` in the generation diff.
