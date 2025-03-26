const systemtray = await Service.import("systemtray");

export const systrayButtons = () => {
  const items = systemtray.bind("items").as((items) =>
    items.map((item) =>
      Widget.Button({
        className: "transparent-button",
        child: Widget.Icon({ icon: item.bind("icon") }),
        onPrimaryClickRelease: (_, event) => item.activate(event),
        onSecondaryClickRelease: (_, event) => item.openMenu(event),
        tooltipMarkup: item.bind("tooltip_markup"),
      }),
    ),
  );

  return Widget.Box({
    children: items,
  });
};
