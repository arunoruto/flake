import brightness from "../service/brightness";

export const brightnessButton = () =>
  Widget.Button({
    className: "transparent-button",
    onPrimaryClickRelease: () => Utils.execAsync("wdisplays"),
    child: Widget.Box({
      children: [
        // Widget.Icon({
        //   icon: "video-display",
        // }),
        Widget.Label({
          label: "⛭",
        }),
        Widget.Label({
          css: "margin-left: 6px;",
          label: brightness
            .bind("screen-value")
            .as((v) => `${Math.round(100 * v)} %`),
          visible: brightness.bind("screen-value").as((v) => v > 0),
        }),
      ],
    }),
  });
