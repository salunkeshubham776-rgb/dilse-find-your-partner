import OQL "mo:caffeineai-oql";
import Common "common";

module {
  public func _toRow(self : Common.Gender) : OQL.Value =
    #text(switch (self) {
      case (#male) { "male" };
      case (#female) { "female" };
      case (#nonBinary) { "nonBinary" };
      case (#other) { "other" };
    });
};
