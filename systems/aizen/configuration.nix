{
  hosts.tinypc.enable = true;

  fwupd.enable = false;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # 16 GB
    }
  ];

  # systems.tags = [
  #   ""
  # ];
}
