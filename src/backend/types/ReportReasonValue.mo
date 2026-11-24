import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.ReportReason) : OQL.Value =
    #text(switch (self) {
      case (#fakeProfile) { "fakeProfile" };
      case (#harassment) { "harassment" };
      case (#inappropriateContent) { "inappropriateContent" };
      case (#spam) { "spam" };
      case (#underage) { "underage" };
      case (#other) { "other" };
    });
};
