import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.ReportStatus) : OQL.Value =
    #text(switch (self) {
      case (#open) { "open" };
      case (#resolved) { "resolved" };
      case (#dismissed) { "dismissed" };
    });
};
