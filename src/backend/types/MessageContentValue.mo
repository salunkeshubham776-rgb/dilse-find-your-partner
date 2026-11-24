import OQL "mo:caffeineai-oql";
import Chat "chat";

module {
  // Collapse a message body to a single text value: the text itself, or a
  // placeholder for an image so the column type stays stable.
  public func _toRow(self : Chat.MessageContent) : OQL.Value =
    switch (self) {
      case (#text(t)) { #text(t) };
      case (#image(_)) { #text("[image]") };
    };
};
