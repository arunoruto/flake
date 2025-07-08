# Arr 🏴‍☠️

- [radarr](https://radarr.video/) for movies
- [sonarr](https://sonarr.tv/) for shows
- [bazarr](https://www.bazarr.media/) for subtitles

## Auth

After radarr and sonarr have been installed, launch them and setup an auth method (for example form)
and enter some credentials you can remember, but don't worry, we will disable auth in a few seconds.

The config file `config.xml` are located at:

- sonarr: `/var/lib/sonarr/.config/NzbDrone/`,
- radarr: `/var/lib/radarr/.config/Radarr/`.

Open the `config.xml` file in your editor of choice and find the `<AuthenticationMethod>` tag,
and change the contents to `<AuthenticationMethod>External</AuthenticationMethod>`.

> [!NOTE]
> Source: [Servarr/Radarr FAQ](https://wiki.servarr.com/radarr/faq#forced-authentication)

## Connect

Connect Plex and/or Jellyfin to your arr apps. Go to `Settings` -> `Connect` and add the corresponding services.
Ports should be populated with the default values. Host can be set to `localhost`.
Plex needs you to sign in for an auth token. Jellyfin needs an API token which can be obtained from
`Menu` -> `Dashboard` (under `Administration`) -> `API Keys`. Pick a nice name for the key(s).
