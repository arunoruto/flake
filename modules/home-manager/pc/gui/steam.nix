let
  version = "9-4";
  ge-proton = builtins.fetchTarball {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${version}/GE-Proton${version}.tar.gz";
    #tarball-ttl = 604800;
  };
in {
  #home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.steam/root/compatibilitytools.d";
  home.file = {
    ".steam/root/compatibilitytools.d/GE-Proton${version}" = {
      recursive = true;
      source = "${ge-proton}";
    };
    #".steam/text.sha" = ge-proton-sha;
  };
}
