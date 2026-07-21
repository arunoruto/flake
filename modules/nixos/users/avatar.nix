# AccountsService avatar: if the primary user provides a `.face` file in their
# home-manager config, expose it as their login-screen icon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  primaryUserName = config.users.primaryUser;
in
{
  config.systemd.tmpfiles.rules =
    lib.optionals (config.home-manager.users.${primaryUserName}.home.file ? ".face")
      (
        let
          account-service = pkgs.writeTextFile {
            name = "accounts-service-config-${primaryUserName}";
            text = lib.generators.toINI { } {
              User = {
                Session = "gnome";
                Icon = "/var/lib/AccountsService/icons/${primaryUserName}";
                SystemAccount = "false";
              };
            };
          };
        in
        [
          ''C "/var/lib/AccountsService/users/${primaryUserName}" 0600 root root - ${account-service}''
          ''d  "/var/lib/AccountsService/icons" 0755 root root -''
          ''L+ "/var/lib/AccountsService/icons/${primaryUserName}" - - - - ${
            config.home-manager.users.${primaryUserName}.home.file.".face".source
          }''
        ]
      );
}
