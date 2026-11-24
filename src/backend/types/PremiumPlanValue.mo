import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.PremiumPlan) : OQL.Value =
    #text(switch (self) {
      case (#monthly) { "monthly" };
      case (#yearly) { "yearly" };
    });
};
