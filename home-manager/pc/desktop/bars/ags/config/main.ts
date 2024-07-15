import { barWindow } from "src/bar.ts";
import { appLauncherWindow } from "./src/launcher.ts";
import { mediaPlayerWindow } from "src/mediaPlayer.ts";
import { notificationBalloonsWindow } from "./src/notificationPopups.ts";

App.config({
  // style: "./style.css",
  // nix-shell -p dart-sass --run 'sass --no-source-map css/style.scss css/style.css'
  style: "./css/style.css",
  windows: [
    barWindow(),
    notificationBalloonsWindow(),
    appLauncherWindow,
    mediaPlayerWindow(),

    // you can call it, for each monitor
    // Bar(0),
    // Bar(1)
  ],
});

export {};
