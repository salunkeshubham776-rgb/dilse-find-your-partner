import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.PaymentStatus) : OQL.Value =
    #text(switch (self) {
      case (#pending) { "pending" };
      case (#succeeded) { "succeeded" };
      case (#failed) { "failed" };
      case (#cancelled) { "cancelled" };
    });
};
