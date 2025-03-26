const battery = await Service.import("battery");

export const batteryButton = () => {
  if (battery.available) {
    const icon = battery
      .bind("percent")
      .as((p) => `battery-level-${Math.floor(p / 10) * 10}-symbolic`);

    return Widget.Button({
      cursor: "pointer",
      className: "battery transparent-button",
      onPrimaryClickRelease: () => Utils.execAsync("kitty --detach btop"),
      visible: battery.bind("available"),
      child: Widget.Box({
        children: [
          Widget.Icon({ icon }),
          Widget.Label({
            css: `margin-left: 6px;`,
            label: battery
              .bind("percent")
              .as((p) => `${Math.floor(p / 10) * 10}%`),
          }),
        ],
      }),
    });
  } else {
    return Widget.Box({ children: [] });
  }
};
