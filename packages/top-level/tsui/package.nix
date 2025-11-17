{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  xorg,
  darwin,
}:
buildGoModule rec {
  pname = "tsui";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "neuralink";
    repo = "tsui";
    tag = "v${version}";
    hash = "sha256-DVkiZc+7XNgj47T1uZg6bnfoMw+0dP4+72AxfCYKcL4=";
  };

  # Possibly works around sporadic "signal: illegal instruction" error when
  # cross-compiling with macOS Rosetta.
  preBuild =
    if stdenv.isLinux && stdenv.isx86_64 then
      ''
        export GODEBUG=asyncpreemptoff=1
      ''
    else
      null;

  # Inject the version info in the binary.
  ldflags = [
    "-X main.Version=${version}"
  ];

  # This hash locks the dependencies of this package. It is
  # necessary because of how Go requires network access to resolve
  # VCS. See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
  # details. Normally one can build with a fake hash and rely on native Go
  # mechanisms to tell you what the hash should be or determine what
  # it should be "out-of-band" with other tooling (eg. gomod2nix).
  # Remember to bump this hash when your dependencies change.
  vendorHash = "sha256-FIbkPE5KQ4w7Tc7kISQ7ZYFZAoMNGiVlFWzt8BPCf+A=";

  buildInputs =
    [ ]
    ++ (lib.optionals stdenv.isLinux [
      # For Linux clipboard support.
      xorg.libX11.dev
    ])
    ++ (lib.optionals stdenv.isDarwin [
      # For macOS clipboard support.
      darwin.apple_sdk.frameworks.Cocoa
    ]);

  # Un-Nix the build so it can dlopen() X11 outside of Nix environments.
  # preFixup = if stdenv.isLinux then ''
  #   patchelf --remove-rpath --set-interpreter ${linuxInterpreter} $out/bin/${pname}
  # '' else null;
}
