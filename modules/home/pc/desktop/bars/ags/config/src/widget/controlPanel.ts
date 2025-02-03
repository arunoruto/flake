// import { metricsButton } from "./metricsButton";
import { volumeSlider } from "./volumeSlider";
// import { weatherButton } from "./weatherButton";

const network = await Service.import("network");

export const controlPanel = () => {
  const powers = Widget.Box({
    css: `opacity: 1;`,
    children: [
      Widget.Button({
        onPrimaryClickRelease: () => Utils.execAsync("systemctl poweroff"),
        child: Widget.Icon({ icon: "system-shutdown", size: 24 }),
        className: "transparent-button power-button",
      }),
      Widget.Button({
        onPrimaryClickRelease: () => Utils.execAsync("systemctl reboot"),
        child: Widget.Icon({ icon: "system-reboot", size: 24 }),
        className: "transparent-button power-button",
      }),
      Widget.Button({
        onPrimaryClickRelease: () => Utils.execAsync("hyprlock"),
        child: Widget.Icon({ icon: "system-lock-screen", size: 24 }),
        className: "transparent-button power-button",
      }),
    ],
  });

  const wifiWidget = Widget.Button({
    className: "transparent-button",
    cursor: "pointer",
    onPrimaryClickRelease: () => Utils.execAsync("kitty --detach nmtui"),
    onSecondaryClickRelease: () => Utils.execAsync("nm-connection-editor"),
    child: Widget.Box({
      children: [
        Widget.Icon({
          icon: network.wifi.bind("icon_name"),
        }),
        Widget.Label({
          css: `margin-left: 6px;`,
          label: network.wifi.bind("ssid").as((ssid) => ssid || ""),
        }),
      ],
    }),
  });

  const wiredWidget = Widget.Button({
    className: "transparent-button",
    cursor: "pointer",
    onClicked: () => Utils.execAsync("kitty --detach nmtui"),
    onSecondaryClickRelease: () => Utils.execAsync("nm-connection-editor"),
    child: Widget.Icon({
      icon: network.wired.bind("icon_name"),
    }),
    visible: network.bind("primary").as((p) => p == "wired"),
  });

  return Widget.Box({
    className: "control-panel-box",
    vertical: true,
    children: [
      Widget.Box({ css: `opacity: 1;`, children: [wifiWidget, wiredWidget] }),
      // weatherButton(),
      // metricsButton(),
      volumeSlider(),
      powers,
    ],
  });
};
