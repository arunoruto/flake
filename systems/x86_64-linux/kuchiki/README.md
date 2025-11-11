# Enable iGPU

The integrated GPU is usually disabled. The setting is buried deep down...
`Advanced` -> `AMD CBS` -> `NBIO Common Option` -> `GFX Configuration`
Set `iGPU Configuration` to `Auto`, or a different option which suits your need.

# ReBAR

Enable ReBAR via BIOS:

1. Go to `Advance` -> `PCI Subsystem Settings`
2. Enable `Above 4G Decoding`
3. Then `Re-Size BAR Support` appears
4. Set it to auto

# PCIe Bifurcation

Under `Advance` -> `PCI Subsystem Settings` you can bifurcate the PCIe sockets.
Options are:

- x16
- x8 x8
- x8 x4 x4
- x4 x4 x8
- x4 x4 x4 x4
