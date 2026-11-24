import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Profile "../types/profile";
import Matching "../types/matching";
import Chat "../types/chat";
import Premium "../types/premium";
import MatchingLib "../lib/matching";
import ChatLib "../lib/chat";
import ProfileLib "../lib/profile";
import PremiumLib "../lib/premium";

mixin (
  accessControlState : AccessControl.AccessControlState,
  profiles : Map.Map<Common.UserId, Profile.Profile>,
  matches : Map.Map<(Common.UserId, Common.UserId), Matching.Match>,
  messages : Map.Map<Common.Id, Chat.Message>,
  blocks : Map.Map<(Common.UserId, Common.UserId), Chat.Block>,
  subscriptions : Map.Map<Common.UserId, Premium.Subscription>,
) {
  func requireMatchingUser(caller : Common.UserId) {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only users can perform this action");
    };
  };

  func otherOf(m : Matching.Match, caller : Common.UserId) : Common.UserId {
    if (Principal.equal(m.userA, caller)) { m.userB } else { m.userA };
  };

  func toView(m : Matching.Match, caller : Common.UserId, now : Common.Timestamp) : ?Matching.MatchView {
    let otherId = otherOf(m, caller);
    switch (profiles.get(otherId)) {
      case (?other) {
        let last = ChatLib.lastMessage(messages, m.id);
        ?{
          id = m.id;
          other = ProfileLib.toView(other, PremiumLib.isPremium(subscriptions, otherId, now), now);
          createdAt = m.createdAt;
          lastMessagePreview = switch (last) {
            case (?msg) { ?ChatLib.preview(msg.content) };
            case null { null };
          };
          lastMessageAt = switch (last) {
            case (?msg) { ?msg.createdAt };
            case null { null };
          };
          unreadCount = 0;
        };
      };
      case null { null };
    };
  };

  public query ({ caller }) func listMatches() : async [Matching.MatchView] {
    requireMatchingUser(caller);
    let now = Time.now();
    let mine = MatchingLib.forUser(matches, caller);
    mine.filterMap(func m = toView(m, caller, now));
  };

  public query ({ caller }) func getMatch(matchId : Common.Id) : async ?Matching.MatchView {
    requireMatchingUser(caller);
    let now = Time.now();
    switch (matches.values().find(func m = m.id == matchId)) {
      case (?m) {
        if (not (Principal.equal(m.userA, caller) or Principal.equal(m.userB, caller))) {
          return null;
        };
        toView(m, caller, now);
      };
      case null { null };
    };
  };
};
