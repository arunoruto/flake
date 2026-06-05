{
  services.resolved = {
    enable = true;
    extraConfig = ''
      [Resolve]
      DNS=45.90.28.0#957c45.dns.nextdns.io
      DNS=45.90.30.0#957c45.dns.nextdns.io
      DNS=2a07:a8c0::#957c45.dns.nextdns.io
      DNS=2a07:a8c1::#957c45.dns.nextdns.io
      DNSOverTLS=yes
    '';
  };
}
