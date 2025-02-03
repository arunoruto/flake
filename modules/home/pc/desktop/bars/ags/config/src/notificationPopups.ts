import { Notification } from "resource:///com/github/Aylur/ags/service/notifications.js";
// import { truncate } from "./util";

const notifications = await Service.import("notifications");

notifications.popupTimeout = 9000;
notifications.forceTimeout = false;
notifications.cacheActions = false;
notifications.clearDelay = 100;

function notificationIconWidget({ app_entry, app_icon, image }: Notification) {
  if (image) {
    return Widget.Box({
      css:
        `background-image: url("${image}");` +
        "background-size: contain;" +
        "background-repeat: no-repeat;" +
        "background-position: center;",
    });
  }

  let icon = "dialog-information-symbolic";
  if (Utils.lookUpIcon(app_icon)) icon = app_icon;

  if (app_entry && Utils.lookUpIcon(app_entry)) icon = app_entry;

  return Widget.Box({
    child: Widget.Icon(icon),
  });
}

function notificationBoxWidget(n: Notification) {
  const icon = Widget.Box({
    vpack: "start",
    className: "icon",
    child: notificationIconWidget(n),
  });

  const title = Widget.Label({
    className: "notification-title",
    xalign: 0,
    justification: "left",
    hexpand: true,
    max_width_chars: 24,
    truncate: "end",
    wrap: true,
    label: truncate(n.summary, 80),
    use_markup: true,
  });

  const body = Widget.Label({
    className: "notification-body",
    hexpand: true,
    use_markup: true,
    xalign: 0,
    justification: "left",
    label: truncate(n.body, 180),
    wrap: true,
  });

  const actions = Widget.Box({
    className: "actions",
    children: n.actions.map(({ id, label }) =>
      Widget.Button({
        className: "action-button",
        onClicked: () => {
          n.invoke(id);
          n.dismiss();
        },
        hexpand: true,
        child: Widget.Label(label),
      }),
    ),
  });

  return Widget.EventBox(
    {
      attribute: { id: n.id },
      onPrimaryClick: n.dismiss,
      onSecondaryClick: n.dismiss,
    },
    Widget.Box(
      {
        className: `notification ${n.urgency}`,
        vertical: true,
      },
      Widget.Box([icon, Widget.Box({ vertical: true }, title, body)]),
      actions,
    ),
  );
}

export function notificationBalloonsWindow(monitor = 0) {
  const list = Widget.Box({
    vertical: true,
    children: notifications.popups.map(notificationBoxWidget),
  });

  const onNotified = (_: any, id: number) => {
    const n = notifications.getNotification(id);
    if (n) list.children = [...list.children, notificationBoxWidget(n)];
  };

  const onDismissed = (_: any, id: number) => {
    list.children.find((n) => n.attribute.id === id)?.destroy();
  };

  list
    .hook(notifications, onNotified, "notified")
    .hook(notifications, onDismissed, "dismissed");

  return Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    className: "notification-popups",
    anchor: ["top", "right"],
    child: Widget.Box({
      css: "min-width: 2px; min-height: 2px;",
      className: "notifications",
      vertical: true,
      child: list,
    }),
  });
}
