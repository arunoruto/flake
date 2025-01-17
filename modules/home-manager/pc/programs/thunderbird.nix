{
  pkgs,
  lib,
  config,
  ...
}:
let
  realName = "Mirza Arnaut";
  profiles = [ "mirza-test" ];
in
{
  programs.thunderbird = {
    # package = pkgs.unstable.thunderbird-128;
    package = pkgs.thunderbird;
    profiles = {
      mirza = {
        isDefault = true;
      };
      mirza-test = { };
    };
  };

  accounts.email.accounts = {
    gmail = {
      address = "mirza.arnaut45@gmail.com";
      primary = true;
      flavor = "gmail.com";
      inherit realName;
      thunderbird = {
        enable = true;
        inherit profiles;
      };
    };
    unimail = {
      address = "mirza.arnaut@tu-dortmund.de";
      flavor = "outlook.office365.com";
      signature = {
        showSignature = "append";
        text = ''
          <font face="Arial">M.Sc.<br>
          <a href="https://bv.etit.tu-dortmund.de/professur/arbeitsgruppe/arnaut/">Mirza Arnaut</a> <p style="font-style: italic;">/mɪrzə ərnɐut/</p><br>
          Wissenschaftlicher Mitarbeiter <br>
          <br>
          <strong>Technische Universität Dortmund </strong><br>
          Fakultät Elektro- und Informationstechnik<br>
          Arbeitsgebiet Bildsignalverarbeitung<br>
          Otto-Hahn-Straße 4<br>
          44227 Dortmund <br>
          <br>
          Tel.: +49 231-755 31 90 <br>
          Fax: +49 231-755 36 85 <br>
          <a href="mailto:mirza.arnaut@tu-dortmund.de">mirza.arnaut@tu-dortmund.de </a><br>
          <a href="http://www.tu-dortmund.de/">www.tu-dortmund.de </a><br>
        '';
      };
      inherit realName;
      thunderbird = {
        enable = true;
        inherit profiles;
      };
    };
    dav = {
      address = "mirza.arnaut@dav-dortmund.de";
      flavor = "outlook.office365.com";
      inherit realName;
    };
  };
}
