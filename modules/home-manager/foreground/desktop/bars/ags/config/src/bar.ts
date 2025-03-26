const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");
const mpris = await Service.import("mpris");
const audio = await Service.import("audio");
const battery = await Service.import("battery");
const systemtray = await Service.import("systemtray");

import { batteryButton } from "./widget/batteryButton";
import { brightnessButton } from "./widget/brightnessButton";
import { clockButton } from "./widget/clockButton";
import { systrayButtons } from "./widget/systrayButtons";
import { volumeButton } from "./widget/volumeButton";
import { workspaceButtons } from "./widget/workspaceButtons";

function ClientTitle() {
  return Widget.Label({
    class_name: "client-title",
    label: hyprland.active.client.bind("title"),
    visible: hyprland.active.client.bind("address").as((addr) => !!addr),
  });
}

// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
function Notification() {
  const popups = notifications.bind("popups");
  return Widget.Box({
    class_name: "notification",
    visible: popups.as((p) => p.length > 0),
    children: [
      Widget.Icon({
        icon: "preferences-system-notifications-symbolic",
      }),
      Widget.Label({
        label: popups.as((p) => p[0]?.summary || ""),
      }),
    ],
  });
}

function Media() {
  const label = Utils.watch("", mpris, "player-changed", () => {
    if (mpris.players[0]) {
      const { track_artists, track_title } = mpris.players[0];
      return `${track_artists.join(", ")} - ${track_title}`;
    } else {
      return "Nothing is playing";
    }
  });

  return Widget.Button({
    class_name: "media",
    on_primary_click: () => mpris.getPlayer("")?.playPause(),
    on_scroll_up: () => mpris.getPlayer("")?.next(),
    on_scroll_down: () => mpris.getPlayer("")?.previous(),
    child: Widget.Label({ label }),
  });
}

function Volume() {
  const icons = {
    101: "overamplified",
    67: "high",
    34: "medium",
    1: "low",
    0: "muted",
  };

  function getIcon() {
    const icon = audio.speaker.is_muted
      ? 0
      : [101, 67, 34, 1, 0].find(
          (threshold) => threshold <= audio.speaker.volume * 100,
        );

    return `audio-volume-${icons[icon]}-symbolic`;
  }

  const icon = Widget.Icon({
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
  });

  const slider = () =>
    Widget.Box({
      css: "min-width: 180px",
      child: Widget.Slider({
        hexpand: true,
        draw_value: false,
        on_change: ({ value }) => (audio.speaker.volume = value),
        setup: (self) =>
          self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0;
          }),
      }),
    });

  const label = Widget.Label({
    label: audio.speaker.bind("volume").as((v) => `${Math.round(v * 100)}%`),
  });

  return Widget.Box({
    class_name: "volume",
    children: [icon, label],
    // children: [icon, slider()],
  });
}

import brightness from "./custom/brightness.js";
function Brightness() {
  const slider = Widget.Box({
    css: "min-width: 180px",
    child: Widget.Slider({
      hexpand: true,
      draw_value: false,
      on_change: (self) => (brightness.screen_value = self.value),
      value: brightness.bind("screen_value"),
    }),
  });

  const label = Widget.Label({
    label: brightness.bind("screen_value").as((v) => `⛭ ${v * 100}%`),
    // setup: (self) =>
    //   self.hook(
    //     brightness,
    //     (self, screenValue) => {
    //       // screenValue is the passed parameter from the 'screen-changed' signal
    //       self.label = screenValue ?? 0
    //
    //       // NOTE:
    //       // since hooks are run upon construction
    //       // the passed screenValue will be undefined the first time
    //
    //       // all three are valid
    //       // self.label = `${brightness.screenValue}`
    //       self.label = `${brightness.screen_value}`
    //       // self.label = `${brightness['screen_value']}`
    //     },
    //     'screen-changed',
    //   ),
  });

  return Widget.Box({
    // children: [slider, label],
    children: [label],
  });
}

function BatteryLabel() {
  const value = battery.bind("percent").as((p) => (p > 0 ? p / 100 : 0));
  const icon = battery
    .bind("percent")
    .as((p) => `battery-level-${Math.floor(p / 10) * 10}-symbolic`);

  return Widget.Box({
    class_name: "battery",
    visible: battery.bind("available"),
    children: [
      Widget.Icon({ icon }),
      Widget.Label({ label: battery.bind("percent").as((p) => `${p}%`) }),
      // Widget.LevelBar({
      //   widthRequest: 140,
      //   vpack: 'center',
      //   value,
      // }),
    ],
  });
}

function SysTray() {
  const items = systemtray.bind("items").as((items) =>
    items.map((item) =>
      Widget.Button({
        child: Widget.Icon({ icon: item.bind("icon") }),
        on_primary_click: (_, event) => item.activate(event),
        on_secondary_click: (_, event) => item.openMenu(event),
        tooltip_markup: item.bind("tooltip_markup"),
      }),
    ),
  );

  return Widget.Box({
    children: items,
  });
}

// layout of the bar
const leftBarSection = () => {
  return Widget.Box({
    spacing: 12,
    children: [workspaceButtons()],
    // children: [Workspaces(), ClientTitle()],
  });
};

const centerBarSection = () => {
  return Widget.Box({
    spacing: 12,
    children: [Media(), Notification()],
  });
};

const rightBarSection = () => {
  return Widget.Box({
    hpack: "end",
    spacing: 12,
    children: [
      volumeButton(),
      brightnessButton(),
      batteryButton(),
      clockButton(),
      systrayButtons(),
    ],
  });
};

export const barWindow = (monitor = 0) => {
  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    class_name: "bar",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      className: "bar-center-box",
      start_widget: leftBarSection(),
      center_widget: centerBarSection(),
      end_widget: rightBarSection(),
    }),
  });
};
