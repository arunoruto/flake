# Variable refresh rate on the TV, which needs the EDID corrected first.
#
# The TV hangs off a DisplayPort-to-HDMI protocol converter (Chrontel CH7218)
# rather than the card's HDMI port, because amdgpu cannot speak HDMI 2.1 FRL
# itself and 4K120 needs that bandwidth. The converter is an *active* branch
# device, so `detect_dp()` pins the sink to SIGNAL_TYPE_DISPLAY_PORT and
# amdgpu takes its DisplayPort path when deciding whether FreeSync is
# available (amdgpu_dm_connector.c):
#
#     if (dc_link->dpcd_caps.allow_invalid_MSA_timing_param) {
#             min_vfreq = connector->display_info.monitor_range.min_vfreq;
#             max_vfreq = connector->display_info.monitor_range.max_vfreq;
#             if (max_vfreq - min_vfreq > 10)
#                     freesync_capable = true;
#     }
#
# The converter does set the DPCD ignore-MSA bit (0x0007 reads 0xc1), so the
# only missing ingredient is a refresh-rate range — and that never arrives,
# because `drm_get_monitor_range()` walks away from this EDID three times
# over (drm_edid.c):
#
#     if (drm_edid->edid->revision < 4)                          return;
#     if (!(edid->features & DRM_EDID_FEATURE_CONTINUOUS_FREQ))  return;
#     ...
#     if (range->flags != DRM_EDID_RANGE_LIMITS_ONLY_FLAG)       return;
#
# This TV publishes EDID 1.3, without the continuous-frequency bit, carrying a
# GTF range descriptor. It *does* state its VRR window — VRRmin 48, VRRmax 120
# in the HDMI Forum data block — but nothing in the kernel reads a VRR range
# from there, and amdgpu only consults the HDMI Forum block on the HDMI signal
# path, which a converted sink is not on. So the panel and the GPU both do VRR
# and simply never manage to agree on it, leaving Steam's toggle greyed out
# (gamescope publishes GAMESCOPE_VRR_CAPABLE = 0, which is what Steam reads).
#
# The repair is to hand the kernel a corrected copy of the TV's own EDID.
# Six bytes change and the checksum is recomputed; the timings, the CTA
# extension and the HDR static metadata are untouched —
# edid-decode reports the same 48 declared modes before and after.
#
# One visible side effect, which is not avoidable: the continuous-frequency
# bit is also what gates mode *inference*, so the connector now offers the
# DMT modes that fit the range on top of the modes the EDID declares --
#
#     if (edid->features & DRM_EDID_FEATURE_CONTINUOUS_FREQ)
#             num_modes += add_inferred_modes(connector, drm_edid);
#
# -- which takes Gaming Mode's resolution list from 51 entries to 103, the
# additions being legacy PC timings like 1600x1200@85. There is no way to ask
# for the range without the inference; declared modes are never filtered by
# the range, so narrowing the horizontal limits below would prune them back if
# the clutter ever becomes a nuisance.
{ pkgs, ... }:
let
  # As dumped from the connector: `base64 < /sys/class/drm/card0-DP-1/edid`.
  # Patched at build time rather than checked in pre-modified, so the edits
  # below stay readable and cannot quietly disagree with this comment.
  edidPackage = pkgs.runCommand "edid-sony-tv-vrr" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    base64 -d > original.bin <<'EOF'
    AP///////wBN2csHAQEBAQEhAQOApV14Cg3JoFdHmCcSSEwhCACBgKnAcU+zAAEB
    AQEBAQEBCOgAMPJwWoCwWIoAcqBjAAAeAjqAGHE4LUBYLEUAcqBjAAAeAAAA/ABT
    T05ZIFRWICAqMzAKAAAA/QAXeQ7/dwAKICAgICAgAs8CA1zw4ngCUnZ1YWBmZV9e
    XWICEQMSEwQQHzIPfwcVB1A9FMBXBAFnVAdffAeDDwAAbgMMAEAAuEQrAIABAgME
    athdxAF4gGuDMHjiAMvjBdgA4g8/5gYNAbawBgR0ADDycFqAsFiKAHKgYwAAHgAA
    AAAAAAAAAAAAAAAAAAAAXgIDKfBIP0AiID48BRTnIAACAUbQAOsBRtAATSK2WJiq
    XOd6gcA11/3XAR0AclHQHiBuKFUAcqBjAAAeAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa
    EOF

    mkdir -p "$out/lib/firmware/edid"
    python3 - original.bin "$out/lib/firmware/edid/sony-tv-vrr.bin" <<'EOF'
    import sys

    edid = bytearray(open(sys.argv[1], "rb").read())

    for offset, value in (
        # Structure version 1.3 -> 1.4. Below revision 4 the kernel does not
        # look for a monitor range at all.
        (0x13, 0x04),
        # Video input definition: digital, 12 bits per colour. It said
        # "undefined" before, which was fine while this was a 1.3 EDID —
        # update_display_info() takes bpc from the CTA deep-colour bits and
        # then returns early. At 1.4 it carries on and re-reads bpc from this
        # byte, so leaving it undefined would drop the sink from 12 bpc to 0.
        (0x14, 0xC0),
        # Feature support: set the continuous-frequency bit.
        (0x18, 0x0B),
        # Range descriptor: 23-121 Hz was the range for *modes*. Replace it
        # with the VRR window the HDMI Forum block states, so the compositor
        # gets the real low-framerate-compensation floor rather than trying to
        # drive the panel below it.
        (0x71, 48),
        (0x72, 120),
        # ...and mark the descriptor "range limits only". The kernel rejects
        # the GTF variant because only this one promises the sink accepts
        # every timing in the range, which is exactly what VRR asks of it.
        (0x76, 0x01),
    ):
        edid[offset] = value

    edid[0x7F] = (-sum(edid[0:0x7F])) & 0xFF

    for base in range(0, len(edid), 128):
        assert sum(edid[base : base + 128]) % 256 == 0, f"block at {base} fails checksum"

    open(sys.argv[2], "wb").write(bytes(edid))
    EOF
  '';
in
{
  # DP-1 is the discrete card's DisplayPort; the iGPU only has HDMI-A-1/2, so
  # the name is unambiguous even though card numbering is not stable here.
  hardware.display = {
    edid.packages = [ edidPackage ];
    outputs."DP-1".edid = "sony-tv-vrr.bin";
  };
}
