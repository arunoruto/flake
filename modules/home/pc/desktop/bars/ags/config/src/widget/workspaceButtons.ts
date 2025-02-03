const hyprland = await Service.import("hyprland");

const workspace_name = [
  "一",
  "二",
  "三",
  "四",
  "五",
  "六",
  "七",
  "八",
  "九",
  "十",
];

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

// function Workspaces() {
//   const activeId = hyprland.active.workspace.bind('id')
//   const workspaces = hyprland.bind('workspaces').as((ws) =>
//     ws.map(({ id }) =>
//       Widget.Button({
//         on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
//         child: Widget.Label(`${id}`),
//         class_name: activeId.as((i) => `${i === id ? 'focused' : ''}`),
//       }),
//     ),
//   )
//
//   return Widget.Box({
//     class_name: 'workspaces',
//     children: workspaces,
//   })
// }

export const workspaceButtons = () => {
  const dispatch = (ws) => hyprland.messageAsync(`dispatch workspace ${ws}`);
  const activeId = hyprland.active.workspace.bind("id");
  return Widget.EventBox({
    onScrollUp: () => dispatch("+1"),
    onScrollDown: () => dispatch("-1"),
    child: Widget.Box({
      class_name: "workspaces",
      children: Array.from({ length: 10 }, (_, i) => i + 1).map((i) =>
        Widget.Button({
          attribute: i,
          class_name: activeId.as((id) => `${i === id ? "focused" : ""}`),
          label: workspace_name[i - 1],
          // label: `${i}`,
          on_clicked: () => dispatch(i),
        }),
      ),

      // remove this setup hook if you want fixed number of buttons
      setup: (self) =>
        self.hook(hyprland, () =>
          self.children.forEach((btn) => {
            btn.visible = hyprland.workspaces.some(
              (ws) => ws.id === btn.attribute,
            );
          }),
        ),
    }),
  });
};
