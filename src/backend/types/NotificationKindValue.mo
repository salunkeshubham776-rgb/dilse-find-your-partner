import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.NotificationKind) : OQL.Value =
    #text(switch (self) {
      case (#newMatch) { "newMatch" };
      case (#newMessage) { "newMessage" };
      case (#likedYou) { "likedYou" };
      case (#superLike) { "superLike" };
      case (#subscriptionExpiry) { "subscriptionExpiry" };
    });
};
