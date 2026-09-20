# Per-host nixpkgs `config`, merged over the shared one in systems/default.nix.
# This cannot live in configuration.nix: pkgs is instantiated outside the module
# system, so `nixpkgs.config` is rejected there.
let
  # Insecure packages tolerated on this host, matched by pname.
  insecure = [
    # This machine's wifi needs the out-of-tree Broadcom STA driver, which is
    # unmaintained and still flagged insecure upstream. See the warning in
    # configuration.nix.
    "broadcom-sta"
  ];
in
{
  # `permittedInsecurePackages` compares against the full name-with-version —
  # for this driver `broadcom-sta-6.30.223.271-59-7.2.6`, whose last component
  # is the *kernel* version — so every nixpkgs or kernel bump broke evaluation
  # and needed a new pin. Match on pname instead; the exception is deliberate
  # and permanent for as long as this adapter is in the machine.
  #
  # Note this replaces nixpkgs' default predicate rather than extending it:
  # further exceptions for this host go in the list above, not in
  # `permittedInsecurePackages`.
  allowInsecurePredicate = pkg: builtins.elem (pkg.pname or "") insecure;
}
