import Map "mo:core/Map";
import Common "../types/common";
import Notifications "../types/notifications";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type Notification = Notifications.Notification;
  public type NotificationKind = Common.NotificationKind;

  public func toView(n : Notification) : Notifications.NotificationView {
    {
      id = n.id;
      kind = n.kind;
      title = n.title;
      body = n.body;
      read = n.read;
      createdAt = n.createdAt;
    };
  };

  public func push(
    notifications : Map.Map<Id, Notification>,
    nextId : { var value : Id },
    recipient : UserId,
    kind : NotificationKind,
    title : Text,
    body : Text,
    now : Timestamp,
  ) : Notification {
    let id = nextId.value;
    nextId.value := id + 1;
    let notification : Notification = {
      id;
      recipient;
      kind;
      title;
      body;
      read = false;
      createdAt = now;
    };
    notifications.add(id, notification);
    notification;
  };

  public func forUser(notifications : Map.Map<Id, Notification>, user : UserId) : [Notification] {
    let mine = notifications.values().filter(func n = n.recipient == user).toArray();
    mine.sort(func (a, b) = if (a.createdAt > b.createdAt) { #less } else if (a.createdAt < b.createdAt) { #greater } else { #equal });
  };

  public func unreadCount(notifications : Map.Map<Id, Notification>, user : UserId) : Nat {
    var count = 0;
    for (n in notifications.values()) {
      if (n.recipient == user and not n.read) { count += 1 };
    };
    count;
  };

  public func markRead(
    notifications : Map.Map<Id, Notification>,
    user : UserId,
    notificationId : Id,
  ) : () {
    switch (notifications.get(notificationId)) {
      case (null) {};
      case (?n) {
        if (n.recipient == user and not n.read) {
          notifications.add(notificationId, { n with read = true });
        };
      };
    };
  };

  public func markAllRead(notifications : Map.Map<Id, Notification>, user : UserId) : () {
    let snapshot = notifications.entries().toArray();
    for ((id, n) in snapshot.values()) {
      if (n.recipient == user and not n.read) {
        notifications.add(id, { n with read = true });
      };
    };
  };
};
