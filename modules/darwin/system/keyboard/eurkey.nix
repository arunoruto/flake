{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.keyboard.eurkey.enable =
    lib.mkEnableOption "Install EurKey keyboard layout system-wide"
    // {
      default = true;
    };

  config = lib.mkIf config.keyboard.eurkey.enable {
    # Copy EurKey files to system-wide keyboard layouts directory
    # macOS requires actual files, not symlinks
    system.activationScripts.postActivation.text = lib.mkAfter ''
      echo "Installing EurKey keyboard layout..." >&2

      # Ensure the directory exists
      mkdir -p "/Library/Keyboard Layouts"

      # Copy the layout files (not symlink, actual copy)
      cp -f "${pkgs.eurkey-mac}/share/eurkey/EurKEY.keylayout" "/Library/Keyboard Layouts/EurKEY.keylayout"
      cp -f "${pkgs.eurkey-mac}/share/eurkey/EurKEY.icns" "/Library/Keyboard Layouts/EurKEY.icns"

      # Set proper permissions
      chmod 644 "/Library/Keyboard Layouts/EurKEY.keylayout"
      chmod 644 "/Library/Keyboard Layouts/EurKEY.icns"

      echo "EurKey keyboard layout installed successfully" >&2
    '';
  };
}
