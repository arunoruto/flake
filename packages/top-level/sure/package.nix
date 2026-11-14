{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  defaultGemConfig,
  ruby_3_4,
  tailwindcss_4,
}:
let
  # Upstream's lockfile pins nokogiri and ffi only as prebuilt platform gems,
  # which bundix cannot use; update.sh re-locks it for the `ruby` platform
  # (same versions) and drops the exact `.ruby-version` pin.
  gems = bundlerEnv {
    name = "sure-gems";
    ruby = ruby_3_4;
    gemdir = ./.;
    # ponytail: all groups, like upstream's image minus `development`; filter
    # with `groups` plus BUNDLE_WITHOUT everywhere if the closure size matters.
    gemConfig = defaultGemConfig // {
      tailwindcss-ruby = _: {
        # The `ruby` platform gem ships no binary; point it at nixpkgs'.
        postInstall = ''
          cd "$(cat $out/nix-support/gem-meta/install-path)"
          substituteInPlace lib/tailwindcss/ruby.rb \
            --replace-fail 'ENV["TAILWINDCSS_INSTALL_DIR"]' \
                           'ENV.fetch("TAILWINDCSS_INSTALL_DIR", "${tailwindcss_4}/bin")'
        '';
      };
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sure";
  version = "0.7.6";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "we-promise";
    repo = "sure";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FIjIfhlN/3cX/Pp1fJijQuArwXwRsq8Wn5JrkUgPgI0=";
  };

  nativeBuildInputs = [
    gems
    gems.wrappedRuby
  ];
  buildInputs = [ gems.wrappedRuby ];

  env = {
    RAILS_ENV = "production";
    SECRET_KEY_BASE_DUMMY = "1";
  };

  buildPhase = ''
    runHook preBuild

    export BOOTSNAP_CACHE_DIR=$TMPDIR/bootsnap
    cp ${./Gemfile} Gemfile
    cp ${./Gemfile.lock} Gemfile.lock
    patchShebangs bin
    rails assets:precompile
    rm -rf tmp/cache

    runHook postBuild
  '';

  # The store is read-only: runtime state lives in the service's state dir.
  installPhase = ''
    runHook preInstall

    rm -rf log storage tmp
    ln -s /var/lib/sure/log log
    ln -s /var/lib/sure/storage storage
    ln -s /var/lib/sure/tmp tmp

    mkdir -p $out/share
    cp -r . $out/share/sure

    runHook postInstall
  '';

  passthru = {
    inherit gems;
    inherit (gems) wrappedRuby;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Self-hosted personal finance and wealth management app (community fork of Maybe Finance)";
    homepage = "https://github.com/we-promise/sure";
    changelog = "https://github.com/we-promise/sure/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
})
