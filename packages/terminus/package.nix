{ bundlerApp, fetchFromGitHub }:
bundlerApp rec {
  #   pname = "terminus";
  #   version = "0.30.0";

  #   src = fetchFromGitHub {
  #     owner = "usetrmnl";
  #     repo = "byos_hanami";
  #     rev = "v${version}";
  #     hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  #   };

  #   gemdir = src;
  #   exes = [ "overmind" ];
}
