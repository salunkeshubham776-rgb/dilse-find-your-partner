import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.RelationshipPreference) : OQL.Value =
    #text(switch (self) {
      case (#longTerm) { "longTerm" };
      case (#friendship) { "friendship" };
      case (#casualDating) { "casualDating" };
      case (#openToAll) { "openToAll" };
    });
};
