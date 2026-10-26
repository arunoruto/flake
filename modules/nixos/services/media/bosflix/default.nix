{
  config,
  lib,
  ...
}:
let
  cfg = config.services.bosflix;

  # Every syncthing folder that lives under completedPath, by its directory
  # name, so it can be compared against syncedFolders below.
  sharedOutFolders = map (folder: lib.last (lib.splitString "/" folder.path)) (
    lib.attrValues (
      lib.filterAttrs (
        _: folder: lib.hasPrefix "${cfg.completedPath}/" folder.path
      ) config.services.syncthing.settings.folders
    )
  );
  unmanagedFolders = lib.subtractLists cfg.syncedFolders sharedOutFolders;
in
{
  imports = [
    ./deluge.nix
    ./dirs.nix
    ./indexers.nix
    ./sabnzbd.nix
    ./syncthing.nix
  ];

  options.services.bosflix = {
    enable = lib.mkEnableOption "Enable bosflix services";

    drivePath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/hdd";
      description = "The path to the HDD";
    };

    # Read-only so there is one spelling of each path. These were let-bindings
    # in the old single-file module while ../syncthing/folders.nix recomputed
    # the same strings and sabnzbd's ini held a third copy — any two of those
    # could drift without anything noticing.
    completedPath = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = builtins.toString (cfg.drivePath + "/complete");
      description = ''
        Where the downloaders put finished jobs and what syncthing shares out.
      '';
    };

    incompletedPath = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = builtins.toString (cfg.drivePath + "/incomplete");
      description = "Scratch space for in-progress downloads.";
    };

    mediaGroup = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = ''
        The group shared by the downloaders, syncthing and the *arrs. The host
        is responsible for creating it; see users.groups.media.
      '';
    };

    syncedFolders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "mirza-music"
        "mirza-shows"
        "mirza-movies"
        "tim-shows"
        "tim-movies"
      ];
      description = ''
        Per-consumer folders under completedPath that get synced out to the
        *arr hosts. These are the ones ./dirs.nix gives the setgid +
        group-writable treatment; the matching syncthing folders are declared
        in ../syncthing/folders.nix.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # That list and the folders in ../syncthing/folders.nix have to agree, and
    # for two weeks they did not: tim-shows and tim-movies existed only in
    # syncthing's web UI, so nothing here created them setgid, their contents
    # stayed sabnzbd-owned, and syncthing failed the whole folder on an hourly
    # retry because it could not chmod files it did not own. Catching that at
    # eval time is cheap; catching it in production took a fortnight.
    assertions = [
      {
        assertion = unmanagedFolders == [ ];
        message = ''
          These syncthing folders live under ${cfg.completedPath} but are missing
          from services.bosflix.syncedFolders: ${lib.concatStringsSep ", " unmanagedFolders}.

          Nothing would create them setgid and group-writable, so whatever the
          downloaders write into them stays owned by the downloader and
          syncthing cannot apply metadata to it. Add them to syncedFolders, or
          drop the folder.
        '';
      }
    ];
  };

  # nixpkgs.config cannot be set from a host module (see CLAUDE.md), so this
  # belongs in systems/<arch>/<host>/nixpkgs.nix if it is ever needed again:
  # nixpkgs.config.permittedInsecurePackages = [
  #   "aspnetcore-runtime-6.0.36"
  #   "aspnetcore-runtime-wrapped-6.0.36"
  #   "dotnet-runtime-6.0.36"
  #   "dotnet-runtime-wrapped-6.0.36"
  #   "dotnet-sdk-6.0.428"
  #   "dotnet-sdk-wrapped-6.0.428"
  # ];
}
