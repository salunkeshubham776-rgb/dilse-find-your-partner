import OQL "mo:caffeineai-oql";
import Discover "discover";

module {
  public func _toRow(self : Discover.LikeKind) : OQL.Value =
    #text(switch (self) {
      case (#like) { "like" };
      case (#superLike) { "superLike" };
    });
};
