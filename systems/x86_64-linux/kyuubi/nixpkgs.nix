# Per-host nixpkgs `config`, merged over the shared one in systems/default.nix.
# This cannot live in configuration.nix: pkgs is instantiated outside the module
# system, so `nixpkgs.config` is rejected there.
{
  # This machine's wifi needs the out-of-tree Broadcom STA driver, which is
  # unmaintained and still flagged insecure upstream. See the warning in
  # configuration.nix. Pinned to the exact version on purpose: a nixpkgs bump
  # makes evaluation fail again, which forces a fresh look instead of silently
  # carrying the exception forward.
  permittedInsecurePackages = [ "broadcom-sta-6.30.223.271-59-7.1.5" ];
}
