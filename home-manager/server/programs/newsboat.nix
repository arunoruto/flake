{ ... }:
#let
#  catppuccin-newsboat = builtins.fetchGit {
#    url = "https://github.com/catppuccin/newsboat";
#    ref = "main";
#  };
#in
{
  programs.newsboat = {
    enable = true;
    extraConfig = ''
    include ~/.newsboat/dark
    '';
    urls = [
      {
        title = "Home Assistant";
        tags = [ "smarthome" ];
        url = "https://home-assistant.io/atom.xml";
      }
      {
        title = "Home Assistant Alerts";
        tags = [ "smarthome" ];
        url = "https://alerts.home-assistant.io/feed.xml";
      }
      {
        title = "Home Assistant Developer Docs Blog";
        tags = [ "smarthome" ];
        url = "https://developers.home-assistant.io/blog/rss.xml";
      }
      {
        title = "Blog on Tailscale";
        tags = [ "tailscale" ];
        url = "https://tailscale.com/blog/index.xml";
      }
      {
        title = "Changelog on Tailscale";
        tags = [ "tailscale" ];
        url = "https://tailscale.com/changelog/index.xml";
      }
      {
        title = "Security Bulletins on Tailscale";
        tags = [ "tailscale" ];
        url = "https://tailscale.com/security-bulletins/index.xml";
      }
      {
        title = "Tailscale Community";
        tags = [ "tailscale" ];
        url = "https://tailscale.dev/feed.xml";
      }
      {
        title = "Framework Blog";
        tags = [ "tech" ];
        url = "https://frame.work/de/en/blog.rss";
      }
      {
        title = "This Week in GNOME";
        tags = [ "tech" ];
        url = "https://thisweek.gnome.org/index.xml";
      }
      {
        title = "Traefik Labs: Makes Networking Boring";
        tags = [ "it" ];
        url = "https://traefik.io/rss.xml";
      }
      


    ];
  };

  # Theme for alacritty
  #home.file.".newsboat/latte".source = "${catppuccin-newsboat}/themes/latte";
  #home.file.".newsboat/dark".source = "${catppuccin-newsboat}/themes/dark";
}
