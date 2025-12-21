{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.matlab;

  build-matlab-image = pkgs.writeShellScriptBin "build-matlab-image" ''
    # Load variables from Nix config
    RELEASE="${cfg.release}"
    PRODUCTS="${lib.concatStringsSep " " cfg.products}"

    echo "=== Building MATLAB $RELEASE Custom Image ==="
    echo "Toolboxes: $PRODUCTS"

    # We use Podman (which you enabled in the previous module)
    ${pkgs.podman}/bin/podman build \
      --no-cache \
      --build-arg MATLAB_RELEASE="$RELEASE" \
      --build-arg ADDITIONAL_PRODUCTS="MATLAB $PRODUCTS" \
      -t "matlab:''${RELEASE}-custom" \
      -f ${./Dockerfile} \
      .
      
    echo "=== Build Complete: matlab:''${RELEASE}-custom ==="
  '';

  matlabWrapper = pkgs.writeShellScriptBin "matlab" ''
    RELEASE="${cfg.release}"
    IMAGE="containers-storage:matlab:''${RELEASE}-custom"
    BOX_NAME="matlab-${cfg.release}"
    LICENSE_PATH="${cfg.licenseFile}"

    # Check if the Distrobox container exists
    if ! ${cfg.distroboxPackage}/bin/distrobox list | grep -q "$BOX_NAME"; then
      echo "First time run: Creating container $BOX_NAME..."
      
      ${cfg.distroboxPackage}/bin/distrobox create \
        --name "$BOX_NAME" \
        --image "$IMAGE" \
        --nvidia \
        --volume "$LICENSE_PATH":/licenses/network.lic \
        --yes
    fi

    echo "Starting MATLAB..."
    # We enter the box and run matlab. 
    # MLM_LICENSE_FILE tells matlab where to look for the license we mounted.
    # "$@" passes arguments (like file names) from your host shell to matlab.
    exec ${cfg.distroboxPackage}/bin/distrobox enter "$BOX_NAME" -- \
         /usr/bin/env MLM_LICENSE_FILE=/licenses/network.lic matlab "$@"
  '';

in
{
  options.programs.matlab = {
    enable = lib.mkEnableOption "Matlab Distrobox Container";

    distroboxPackage = lib.mkPackageOption pkgs "distrobox" { };

    release = lib.mkOption {
      type = lib.types.str;
      default = "R2024b";
      description = "Matlab release tag (e.g. R2024b, R2025a)";
    };

    licenseFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to your network.lic file on the host system.";
      example = "/etc/nixos/secrets/network.lic";
    };

    products = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Symbolic_Math_Toolbox" ];
      description = "List of toolboxes to install via MPM.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      build-matlab-image
      matlabWrapper
      # Optional: Add an icon to your desktop menu
      (pkgs.makeDesktopItem {
        name = "matlab";
        desktopName = "MATLAB ${cfg.release}";
        exec = "matlab";
        icon = "matlab";
        categories = [
          "Development"
          "Science"
        ];
      })
    ];
  };
}
