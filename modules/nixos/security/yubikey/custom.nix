{
  pkgs,
  lib,
  config,
  username,
  ...
}:
let
  homedir = if pkgs.stdenv.isLinux then "/home/${username}" else throw "Only setup for Linux!";
  yubikey-up =
    let
      yubikeyIds = lib.concatStringsSep " " (
        lib.mapAttrsToList (name: id: "[${name}]=\"${builtins.toString id}\"") config.yubikey.identifiers
      );
    in
    pkgs.writeShellApplication {
      name = "yubikey-up";
      runtimeInputs = builtins.attrValues { inherit (pkgs) gawk yubikey-manager; };
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        serial=$(ykman list | awk '{print $NF}')
        # If it got unplugged before we ran, just don't bother
        if [ -z "$serial" ]; then
          # FIXME:(yubikey) Warn probably
          exit 0
        fi

        declare -A serials=(${yubikeyIds})

        key_name=""
        for key in "''${!serials[@]}"; do
          if [[ $serial == "''${serials[$key]}" ]]; then
            key_name="$key"
          fi
        done

        if [ -z "$key_name" ]; then
          echo WARNING: Unidentified yubikey with serial "$serial" . Won\'t link an SSH key.
          exit 0
        fi

        echo "Creating links to ${homedir}/id_$key_name"
        ln -sf "${homedir}/.ssh/id_$key_name" ${homedir}/.ssh/id_yubikey
        ln -sf "${homedir}/.ssh/id_$key_name.pub" ${homedir}/.ssh/id_yubikey.pub
      '';
    };
  yubikey-down = pkgs.writeShellApplication {
    name = "yubikey-down";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      rm ${homedir}/.ssh/id_yubikey
      rm ${homedir}/.ssh/id_yubikey.pub
    '';
  };
in
{
  options.yubikey.custom.enable = lib.mkEnableOption "Custom yubikey scripts for plugin in/out";

  config = lib.mkIf config.yubikey.custom.enable {
    environment.systemPackages = [
      yubikey-up
      yubikey-down
    ];

    services = {
      udev.extraRules = ''
        # Link/unlink ssh key on yubikey add/remove
        SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"
        # NOTE: Yubikey 4 has a ID_VENDOR_ID on remove, but not Yubikey 5 BIO, whereas both have a HID_NAME.
        # Yubikey 5 HID_NAME uses "YubiKey" whereas Yubikey 4 uses "Yubikey", so matching on "Yubi" works for both
        SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"

        ##
        # Yubikey 4
        ##

        # Lock the device if you remove the yubikey (use udevadm monitor -p to debug)
        # #ENV{ID_MODEL_ID}=="0407", # This doesn't match all the newer keys
        # FIXME:(yubikey) We only want this to happen if we're undocked, so we need to see how that works. We probably need to run a
        # script that does smarter checks
        # ACTION=="remove",\
        #  ENV{ID_BUS}=="usb",\
        #  ENV{ID_VENDOR_ID}=="1050",\
        #  ENV{ID_VENDOR}=="Yubico",\
        #  RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"

        ##
        # Yubikey 5 BIO
        #
        # NOTE: The remove event for the bio doesn't include the ID_VENDOR_ID for some reason, but we can use the
        # hid name instead. Some HID_NAME might be "Yubico YubiKey OTP+FIDO+CCID" or "Yubico YubiKey FIDO", etc so just
        # match on "Yubico YubiKey"
        ##

        # SUBSYSTEM=="hid",\
        #  ACTION=="remove",\
        #  ENV{HID_NAME}=="Yubico YubiKey FIDO",\
        #  RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"

        # FIXME:(yubikey) Change this so it only wakes up the screen to the login screen, xset cmd doesn't work
        # SUBSYSTEM=="hid",\
        #  ACTION=="add",\
        #  ENV{HID_NAME}=="Yubico YubiKey FIDO",\
        #  RUN+="${pkgs.systemd}/bin/loginctl activate 1"
        #  #RUN+="${lib.getBin pkgs.xorg.xset}/bin/xset dpms force on"
      '';
    };
  };
}
