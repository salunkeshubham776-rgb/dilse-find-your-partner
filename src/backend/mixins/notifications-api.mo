import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Notifications "../types/notifications";
import NotificationsLib "../lib/notifications";

mixin (
  accessControlState : AccessControl.AccessControlState,
  notifications : Map.Map<Common.Id, Notifications.Notification>,
  nextNotificationId : { var value : Common.Id },
) {
  func requireNotificationsUser(caller : Principal) : () {
    if (caller.isAnonymous()) {
      Runtime.trap("Sign in to continue");
    };
  };

  public query ({ caller }) func listNotifications() : async [Notifications.NotificationView] {
    requireNotificationsUser(caller);
    NotificationsLib.forUser(notifications, caller).map(func n = NotificationsLib.toView(n));
  };

  public query ({ caller }) func unreadNotificationCount() : async Nat {
    requireNotificationsUser(caller);
    NotificationsLib.unreadCount(notifications, caller);
  };

  public shared ({ caller }) func markNotificationRead(notificationId : Common.Id) : async () {
    requireNotificationsUser(caller);
    NotificationsLib.markRead(notifications, caller, notificationId);
  };

  public shared ({ caller }) func markAllNotificationsRead() : async () {
    requireNotificationsUser(caller);
    NotificationsLib.markAllRead(notifications, caller);
  };

  // Subscription expiry reminder for the caller's own premium subscription.
  public shared ({ caller }) func notifySubscriptionExpiry(expiresAt : Common.Timestamp) : async () {
    requireNotificationsUser(caller);
    ignore NotificationsLib.push(
      notifications,
      nextNotificationId,
      caller,
      #subscriptionExpiry,
      "Subscription expiring",
      "Your premium subscription expires soon. Renew to keep your benefits.",
      Time.now(),
    );
  };
};
