# Shared by NixOS and Darwin: roots dropped from the system trust store.
#
# eMudhra's TLS intermediates had their keys compromised (October 2026). NSS
# 3.131.1 removed these three emSign roots, but our `nixpkgs` input still
# ships cacert 3.126, so distrust them here until the lock carries the newer
# bundle — at which point this file goes away. Only `emSign Root CA - G1`
# stays trusted, matching NSS.
{
  security.pki.caCertificateBlacklist = [
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];
}
