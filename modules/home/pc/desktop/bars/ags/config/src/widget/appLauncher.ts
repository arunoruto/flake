import { Application } from "resource:///com/github/Aylur/ags/service/applications.js";

const { query } = await Service.import("applications");

const appLauncherEntry = (app: Application) =>
  Widget.Button({
    className: "transparent-button",
    onClicked: () => {
      App.closeWindow("appLauncherWindow");
      app.launch();
    },
    attribute: { app },
    child: Widget.Box({
      children: [
        Widget.Icon({
          icon: app.icon_name || "",
          size: 42,
        }),
        Widget.Label({
          className: "app-launcher-entry-title",
          label: app.name,
          xalign: 0,
          vpack: "center",
          truncate: "end",
        }),
        Widget.Label({
          className: "app-launcher-entry-description",
          label: app.description,
          xalign: 0,
          vpack: "center",
          truncate: "end",
        }),
      ],
    }),
  });

export const appLauncher = ({ width = 600, height = 500, spacing = 12 }) => {
  // list of application buttons
  let applications = query("").map(appLauncherEntry);

  // container holding the buttons
  const list = Widget.Box({
    vertical: true,
    children: applications,
    spacing,
  });

  // repopulate the box, so the most frequent apps are on top of the list
  function repopulate() {
    applications = query("").map(appLauncherEntry);
    list.children = applications;
  }

  // search entry
  const entry = Widget.Entry({
    hexpand: true,
    css: `margin-bottom: ${spacing}px;`,

    // to launch the first item on Enter
    on_accept: () => {
      // make sure we only consider visible (searched for) applications
      const results = applications.filter((item) => item.visible);
      if (results[0]) {
        App.toggleWindow("appLauncherWindow");
        results[0].attribute.app.launch();
      }
    },

    // filter out the list
    on_change: ({ text }) =>
      applications.forEach((item) => {
        item.visible = item.attribute.app.match(text ?? "");
      }),
  });

  return Widget.Box({
    vertical: true,
    className: "app-list",
    children: [
      entry,

      // wrap the list in a scrollable
      Widget.Scrollable({
        hscroll: "never",
        css: `min-width: ${width}px;` + `min-height: ${height}px;`,
        child: list,
      }),
    ],
    setup: (self) => {
      self.hook(App, (_, windowName, visible) => {
        if (windowName !== "appLauncherWindow") return;

        // when the applauncher shows up
        if (visible) {
          repopulate();
          entry.text = "";
          entry.grab_focus();
        }
      });
      // self.keybind(["CONTROL"], "p", () => {
      // 	App.closeWindow(WINDOW_NAME);
      // })
      // self.keybind(["CONTROL"], "n", () => {
      // 	self.event(KeyPre)
      // })
    },
  });
};
