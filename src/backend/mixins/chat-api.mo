import Map "mo:core/Map";
import List "mo:core/List";
import Int "mo:core/Int";
import Char "mo:core/Char";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Profile "../types/profile";
import Matching "../types/matching";
import Chat "../types/chat";
import Premium "../types/premium";
import ChatLib "../lib/chat";
import ProfileLib "../lib/profile";
import MatchingLib "../lib/matching";
import PremiumLib "../lib/premium";

mixin (
  accessControlState : AccessControl.AccessControlState,
  profiles : Map.Map<Common.UserId, Profile.Profile>,
  matches : Map.Map<(Common.UserId, Common.UserId), Matching.Match>,
  messages : Map.Map<Common.Id, Chat.Message>,
  nextMessageId : { var value : Common.Id },
  blocks : Map.Map<(Common.UserId, Common.UserId), Chat.Block>,
  reports : Map.Map<Common.Id, Chat.Report>,
  nextReportId : { var value : Common.Id },
  readState : Map.Map<(Common.Id, Common.UserId), Common.Timestamp>,
  subscriptions : Map.Map<Common.UserId, Premium.Subscription>,
) {
  func requireChatUser(caller : Common.UserId) {
    ignore AccessControl.getUserRole(accessControlState, caller);
  };

  func chatOtherOf(match_ : Matching.Match, caller : Common.UserId) : Common.UserId {
    if (match_.userA == caller) { match_.userB } else { match_.userA };
  };

  func findMatch(matchId : Common.Id) : ?Matching.Match {
    var found : ?Matching.Match = null;
    for (match_ in matches.values()) {
      if (match_.id == matchId) {
        found := ?match_;
      };
    };
    found;
  };

  func toConversation(match_ : Matching.Match, caller : Common.UserId, now : Common.Timestamp) : ?Chat.ConversationView {
    let other = chatOtherOf(match_, caller);
    switch (profiles.get(other)) {
      case (?profile) {
        let last = ChatLib.lastMessage(messages, match_.id);
        ?{
          matchId = match_.id;
          other = ProfileLib.toView(profile, PremiumLib.isPremium(subscriptions, other, now), now);
          lastMessagePreview = switch (last) {
            case (?m) { ?ChatLib.preview(m.content) };
            case null { null };
          };
          lastMessageAt = switch (last) {
            case (?m) { ?m.createdAt };
            case null { null };
          };
          unreadCount = ChatLib.unreadCount(messages, readState, match_.id, caller);
        };
      };
      case null { null };
    };
  };

  public query ({ caller }) func listConversations() : async [Chat.ConversationView] {
    requireChatUser(caller);
    let now = Time.now();
    let collected = List.empty<Chat.ConversationView>();
    for (match_ in matches.values()) {
      if (match_.userA == caller or match_.userB == caller) {
        let other = chatOtherOf(match_, caller);
        if (not ChatLib.isBlocked(blocks, caller, other)) {
          switch (toConversation(match_, caller, now)) {
            case (?view) { collected.add(view) };
            case null {};
          };
        };
      };
    };
    collected.toArray().sort(func (a, b) = Int.compare(b.lastMessageAt ?? 0, a.lastMessageAt ?? 0));
  };

  public query ({ caller }) func getMessages(matchId : Common.Id) : async [Chat.Message] {
    requireChatUser(caller);
    switch (findMatch(matchId)) {
      case (?match_) {
        if (match_.userA != caller and match_.userB != caller) {
          return [];
        };
        ChatLib.history(messages, matchId);
      };
      case null { [] };
    };
  };

  public shared ({ caller }) func sendMessage(matchId : Common.Id, content : Chat.MessageContent) : async { #ok : Chat.Message; #err : Common.ApiError } {
    requireChatUser(caller);
    switch (findMatch(matchId)) {
      case (?match_) {
        if (match_.userA != caller and match_.userB != caller) {
          return #err(#unauthorized);
        };
        let other = chatOtherOf(match_, caller);
        if (ChatLib.isBlocked(blocks, caller, other)) {
          return #err(#unauthorized);
        };
        switch (content) {
          case (#text(t)) {
            if (t.trim(#predicate(func c = c.isWhitespace())) == "") {
              return #err(#invalidInput("Message cannot be empty"));
            };
          };
          case (#image(_)) {};
        };
        #ok(ChatLib.send(messages, nextMessageId, matchId, caller, content, Time.now()));
      };
      case null { #err(#notFound) };
    };
  };

  public shared ({ caller }) func markConversationRead(matchId : Common.Id) : async () {
    requireChatUser(caller);
    switch (findMatch(matchId)) {
      case (?match_) {
        if (match_.userA != caller and match_.userB != caller) {
          return;
        };
        ChatLib.markRead(readState, matchId, caller, Time.now());
      };
      case null {};
    };
  };

};
