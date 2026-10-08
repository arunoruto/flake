{
  lib,
  config,
  stdenvNoCC,
  mpm,
  cacert,
}:

# Downloads a single MATLAB product with `mpm download --no-deps`. The matlab
# package merges several of these into one source for `mpm install`.
{
  release,
  # Without a pinned update, mpm resolves to the latest one and the hash drifts.
  update,
  product ? "MATLAB",
  platform ? "glnxa64",
  hash ? lib.fakeHash,
  acceptLicense ? config.matlab.acceptLicense or false,
}:

assert lib.assertMsg acceptLicense ''
  Downloading ${product} with mpm means accepting the MathWorks Software License
  Agreement. Its text ships as license_agreement.txt in every MATLAB install, see
  https://www.mathworks.com/matlabcentral/answers/1979884-where-can-i-find-the-mathworks-software-license-agreement

  Accept it by setting `nixpkgs.config.matlab.acceptLicense = true;`, or by
  passing `acceptLicense = true` to fetchMatlab or matlab.
'';

stdenvNoCC.mkDerivation {
  name = "matlab-${release}U${toString update}-${product}";

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [ mpm ];

  buildCommand = ''
    export HOME=$TMPDIR
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mpm download \
      --release=${release}U${toString update} \
      --products=${product} \
      --platforms=${platform} \
      --no-deps \
      --destination=$out
    # A copy of the mpm launcher; not needed for installing, and it would tie
    # every hash to the mpm version.
    rm -r $out/mpm
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
}
