import { appLauncher } from "./widget/appLauncher";
import { controlPanel } from "./widget/controlPanel";

// there needs to be only one instance
export const appLauncherWindow = Widget.Window({
  name: "appLauncherWindow",
  setup: (self) => {
    self.keybind("Escape", () => {
      App.closeWindow("appLauncherWindow");
    });
    self.keybind(["CONTROL"], "g", () => {
      App.closeWindow("appLauncherWindow");
    });
  },
  visible: false,
  keymode: "exclusive",
  child: Widget.Box({
    children: [
      controlPanel(),
      appLauncher({
        width: 600,
        height: 500,
        spacing: 12,
      }),
    ],
  }),
  className: "app-launcher-window",
});
