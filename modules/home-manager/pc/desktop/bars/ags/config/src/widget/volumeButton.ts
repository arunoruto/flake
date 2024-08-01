const audio = await Service.import("audio");

export const volumeButton = () =>
  Widget.Button({
    className: "transparent-button",
    cursor: "pointer",
    onPrimaryClickRelease: () => Utils.execAsync("ags -t mediaPlayerWindow"),
    onSecondaryClickRelease: () => Utils.execAsync("pavucontrol"),
    child: Widget.Box({
      children: [
        Widget.Icon().hook(audio.speaker, (self) => {
          const vol = audio.speaker.volume * 100;
          const icon = [
            [101, "overamplified"],
            [67, "high"],
            [34, "medium"],
            [1, "low"],
            [0, "muted"],
            // @ts-ignore
          ].find(([threshold]) => threshold <= vol)?.[1];

          self.icon = `audio-volume-${icon}-symbolic`;
          self.tooltip_text = `Volume ${Math.floor(vol)}%`;
        }),
        Widget.Label({ css: `margin-left: 6px;` }).hook(
          audio.speaker,
          (self) => {
            const vol = audio.speaker.volume * 100;
            self.label = `${Math.floor(vol)}%`;
          },
        ),
      ],
    }),
  });
