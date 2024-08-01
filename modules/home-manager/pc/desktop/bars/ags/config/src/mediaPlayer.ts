import { MprisPlayer } from "types/service/mpris";

const mpris = await Service.import("mpris");
const players = mpris.bind("players");

const FALLBACK_ICON = "audio-x-generic-symbolic";
const PLAY_ICON = "media-playback-start-symbolic";
const PAUSE_ICON = "media-playback-pause-symbolic";
const PREV_ICON = "media-skip-backward-symbolic";
const NEXT_ICON = "media-skip-forward-symbolic";

function lengthStr(length: number) {
  const min = Math.floor(length / 60);
  const sec = Math.floor(length % 60);
  const sec0 = sec < 10 ? "0" : "";
  return `${min}:${sec0}${sec}`;
}

function player(player: MprisPlayer) {
  const img = Widget.Box({
    className: "img",
    vpack: "start",
    css: player.bind("cover_path").transform(
      (p) => `
            background-image: url('${p}');
        `,
    ),
  });

  const title = Widget.Label({
    className: "title",
    wrap: true,
    hpack: "start",
    label: player.bind("track_title"),
  });

  const artist = Widget.Label({
    className: "artist",
    wrap: true,
    hpack: "start",
    label: player.bind("track_artists").transform((a) => a.join(", ")),
  });

  const positionSlider = Widget.Slider({
    className: "position",
    drawValue: false,
    on_change: ({ value }) => (player.position = value * player.length),
    setup: (self) => {
      const update = () => {
        self.visible = player.length > 0;
        self.value = player.position / player.length;
      };
      self.hook(player, update);
      self.hook(player, update, "position");
      self.poll(1000, update);
    },
  });

  const positionLabel = Widget.Label({
    className: "position",
    hpack: "start",
    setup: (self) => {
      const update = (_: any, time: number) => {
        self.label = lengthStr(time || player.position);
        self.visible = player.length > 0;
      };

      self.hook(player, update, "position");
      // @ts-ignore
      self.poll(1000, update);
    },
  });

  const lengthLabel = Widget.Label({
    className: "length",
    hpack: "end",
    visible: player.bind("length").transform((l) => l > 0),
    label: player.bind("length").transform(lengthStr),
  });

  const icon = Widget.Icon({
    class_name: "icon",
    hexpand: true,
    hpack: "end",
    vpack: "start",
    tooltipText: player.identity || "",
    icon: player.bind("entry").transform((entry) => {
      const name = `${entry}-symbolic`;
      return Utils.lookUpIcon(name) ? name : FALLBACK_ICON;
    }),
  });

  const playPause = Widget.Button({
    class_name: "play-pause",
    onClicked: () => player.playPause(),
    visible: player.bind("can_play"),
    child: Widget.Icon({
      icon: player.bind("play_back_status").transform((s) => {
        switch (s) {
          case "Playing":
            return PAUSE_ICON;
          case "Paused":
          case "Stopped":
            return PLAY_ICON;
        }
      }),
    }),
  });

  const prev = Widget.Button({
    onClicked: () => player.previous(),
    visible: player.bind("can_go_prev"),
    child: Widget.Icon(PREV_ICON),
  });

  const next = Widget.Button({
    onClicked: () => player.next(),
    visible: player.bind("can_go_next"),
    child: Widget.Icon(NEXT_ICON),
  });

  return Widget.Box(
    { class_name: "player" },
    img,
    Widget.Box(
      {
        vertical: true,
        hexpand: true,
      },
      Widget.Box([title, icon]),
      artist,
      Widget.Box({ vexpand: true }),
      positionSlider,
      Widget.CenterBox({
        startWidget: positionLabel,
        centerWidget: Widget.Box([prev, playPause, next]),
        endWidget: lengthLabel,
      }),
    ),
  );
}

export function mediaPlayerWidget() {
  return Widget.Box({
    vertical: true,
    css: "min-height: 2px; min-width: 2px;", // small hack to make it visible
    visible: players.as((p) => p.length > 0),
    children: players.as((p) => p.map(player)),
  });
}

export function mediaPlayerWindow() {
  return Widget.Window({
    name: "mediaPlayerWindow",
    anchor: ["top", "right"],
    child: mediaPlayerWidget(),
    visible: false,
  });
}

// function mediaWidget() {
//   const label = Utils.watch("", mpris, "player-changed", () => {
//     if (mpris.players[0]) {
//       const { track_artists, track_title } = mpris.players[0];
//       return `${track_artists.join(", ")} - ${track_title}`;
//     } else {
//       return "Nothing is playing";
//     }
//   });

//   return Widget.Button({
//     class_name: "media",
//     on_primary_click: () => mpris.getPlayer("")?.playPause(),
//     on_scroll_up: () => mpris.getPlayer("")?.next(),
//     on_scroll_down: () => mpris.getPlayer("")?.previous(),
//     child: Widget.Label({ label }),
//   });
// }
