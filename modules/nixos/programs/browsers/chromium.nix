{ config, lib, ... }:
{
  config = lib.mkIf config.programs.chromium.enable {
    # Any file in the managed policy dir (stylix drops one for the theme
    # colour) makes Chrome "managed", and a managed Chrome greys out the
    # Secure DNS toggle. Forcing DoH by policy turns it back on, and it is
    # what lets Chrome fetch HTTPS/ECH records and encrypt the SNI, which
    # gets past networks that reset TLS handshakes by hostname.
    programs.chromium.extraOpts = {
      DnsOverHttpsMode = "secure";
      DnsOverHttpsTemplates = "https://cloudflare-dns.com/dns-query";
    };
  };
}
