const date = Variable("", {
  poll: [1000, 'date "+%Hh %Mm | %e %b"'],
});

export const clockButton = () => {
  return Widget.Button({
    className: "transparent-button",
    cursor: "pointer",
    onClicked: () => Utils.execAsync("gnome-clocks"),
    child: Widget.Label({
      className: "clock",
      label: date.bind(),
    }),
  });
};
