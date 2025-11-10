{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "lovelylain";
  domain = "ingress";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "lovelylain";
    repo = "hass_ingress";
    tag = version;
    # tag = "v${version}";
    hash = "sha256-jjig0Dl/vdeuN7e25CH5L/Xvc60RM3BiAt3jUw/C9q4=";
  };

  dependencies = [
    # pyopensprinkler
  ];

  meta = {
    changelog = "https://github.com/lovelylain/hass_ingress/releases/tag/${src.tag}";
    description = "Additional ingress panels for the Home Assistant frontend";
    homepage = "https://github.com/lovelylain/hass_ingress";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mit;
  };
}
