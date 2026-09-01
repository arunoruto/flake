# Hardware tuning derived from the facter report — the bridge between
# nixos-facter and nixos-hardware.
#
# The two projects answer different questions and do not know about each
# other: nixos-facter's modules answer *what is present* (bluetooth, initrd
# modules, microcode, virtualisation), while nixos-hardware's common/ tree
# answers *how to run it well* (amd-pstate, GuC submission, per-generation
# media stacks, fstrim). This file reads the former and selects from the
# latter.
#
# It has to live here, at module-list assembly, rather than inside a module:
# several nixos-hardware profiles carry nested `imports` (a CPU generation
# pulls in its iGPU stack), and imports cannot depend on `config` — so the
# report is read as a plain file and the profile list is computed statically.
# `config.facter.hardwareProfiles` records what was chosen, for inspection:
#
#   nix eval .#nixosConfigurations.<host>.config.facter.hardwareProfiles
#
# The mapping is deliberately conservative: an unrecognised CPU gets microcode
# handling and nothing else, and anything opinionated (NVIDIA driver flavour,
# laptop power policy) stays a per-host decision. Extend the table as new
# hardware joins the fleet and its mapping is verified.
{ lib, inputs }:
report:
let
  common = inputs.nixos-hardware.outPath + "/common";

  cpus = report.hardware.cpu or [ ];
  cpu = if cpus == [ ] then { } else builtins.head cpus;
  vendor = cpu.vendor_name or "";
  family = cpu.family or (-1);
  model = cpu.model or (-1);

  gpuDrivers = map (card: card.driver or "") (report.hardware.graphics_card or [ ]);
  # The i915/xe check keeps CPUs whose iGPU is absent (server parts) or
  # disabled in the BIOS from dragging in a media stack for hardware the
  # kernel never bound a driver to.
  hasIntelGpu = builtins.elem "i915" gpuDrivers || builtins.elem "xe" gpuDrivers;

  # cpuid model → nixos-hardware generation directory, for family 6. Model
  # numbers follow the kernel's arch/x86/include/asm/intel-family.h; only
  # client parts are listed, since the iGPU gate above already reduces server
  # parts to the microcode-only path. Note 0x9E (158) strictly covers Kaby
  # Lake desktop as well as Coffee Lake — same core, same Gen9.5 graphics —
  # and the coffee-lake profile is correct for both.
  intelGenerations = {
    "42" = "sandy-bridge";
    "60" = "haswell";
    "69" = "haswell";
    "70" = "haswell";
    "61" = "broadwell";
    "71" = "broadwell";
    "78" = "skylake";
    "94" = "skylake";
    "142" = "kaby-lake";
    "158" = "coffee-lake";
    "125" = "ice-lake";
    "126" = "ice-lake";
    "140" = "tiger-lake";
    "141" = "tiger-lake";
    "165" = "comet-lake";
    "166" = "comet-lake";
    "151" = "alder-lake";
    "154" = "alder-lake";
    # 0xBE: intel-family.h calls it ATOM_GRACEMONT (né Alder Lake-N) — the
    # E-core-only N-series parts, Twin Lake refreshes included (sado's N150).
    # Same Gen12 iGPU as Alder Lake proper, so the same profile fits.
    "190" = "alder-lake";
    "183" = "raptor-lake";
    "186" = "raptor-lake";
    "191" = "raptor-lake";
    "170" = "meteor-lake";
  };
  intelGen = intelGenerations.${toString model} or null;

  # NVMe is the one storage class the report identifies unambiguously (by
  # driver). A SATA SSD is *undetectable*: the disk entries carry no
  # rotational flag or feature list at all (checked against every report in
  # this fleet — kenpachi's SATA flash module reads identically to a spinning
  # Toshiba), so a host with only SATA SSDs still warrants a manual
  # common/pc/ssd import until nixos-facter learns to record
  # /sys/block/*/queue/rotational.
  hasNvme = lib.any (disk: (disk.driver or "") == "nvme") (report.hardware.disk or [ ]);

  # SMBIOS chassis types that mean "runs on a battery, lives on a lap":
  # Portable (8), Laptop (9), Notebook (10), Sub Notebook (14), Tablet (30),
  # Convertible (31), Detachable (32). The report stores chassis as an object
  # on some machines and a one-element list on others, hence the toList.
  laptopChassisTypes = [
    8
    9
    10
    14
    30
    31
    32
  ];
  isLaptop = lib.any (chassis: builtins.elem (chassis.chassis_type.value or 0) laptopChassisTypes) (
    lib.toList (report.smbios.chassis or [ ])
  );

  profiles =
    lib.optionals (vendor == "GenuineIntel" && family == 6) (
      if intelGen != null && hasIntelGpu then
        [ "cpu/intel/${intelGen}" ]
      else
        # Unknown generation, or no working iGPU: microcode still applies.
        [ "cpu/intel/cpu-only.nix" ]
    )
    ++ lib.optionals (vendor == "AuthenticAMD") (
      # amd-pstate needs CPPC, which every part from Zen 3 (family 25) has;
      # pstate.nix imports the plain cpu/amd microcode module itself.
      if family >= 25 then [ "cpu/amd/pstate.nix" ] else [ "cpu/amd" ]
    )
    ++ lib.optional hasNvme "pc/ssd"
    # TLP power management, unless something already claimed the job:
    # pc/laptop's tlp.enable is a mkDefault gated on power-profiles-daemon
    # being off, so a desktop-tagged host running PPD sees a no-op.
    ++ lib.optional isLaptop "pc/laptop";
in
{
  imports = map (profile: "${common}/${profile}") profiles;

  options.facter.hardwareProfiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = profiles;
    defaultText = lib.literalMD "hardware dependent";
    readOnly = true;
    description = ''
      The nixos-hardware `common/` profiles selected from this host's facter
      report by `systems/hardware-profiles.nix`. Read-only — the list exists
      so a host's derived tuning can be inspected, not steered; profile
      *effects* are all `mkDefault` and can be overridden individually.
    '';
  };
}
