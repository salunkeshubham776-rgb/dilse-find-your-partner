import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Profile "../types/profile";
import Discover "../types/discover";
import Matching "../types/matching";
import Chat "../types/chat";
import Premium "../types/premium";
import DiscoverLib "../lib/discover";
import MatchingLib "../lib/matching";
import ProfileLib "../lib/profile";
import PremiumLib "../lib/premium";

mixin (
  accessControlState : AccessControl.AccessControlState,
  profiles : Map.Map<Common.UserId, Profile.Profile>,
  likes : Map.Map<(Common.UserId, Common.UserId), Discover.Like>,
  passes : Map.Map<(Common.UserId, Common.UserId), Discover.Pass>,
  blocks : Map.Map<(Common.UserId, Common.UserId), Chat.Block>,
  matches : Map.Map<(Common.UserId, Common.UserId), Matching.Match>,
  nextMatchId : { var value : Common.Id },
  subscriptions : Map.Map<Common.UserId, Premium.Subscription>,
  superLikes : Map.Map<Common.UserId, Nat>,
) {
  func requireDiscoverUser(caller : Common.UserId) {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only users can perform this action");
    };
  };

  // Likes the caller has already sent today (UTC day).
  func likesUsedToday(caller : Common.UserId, now : Common.Timestamp) : Nat {
    let dayStart = (now / PremiumLib.dayNs) * PremiumLib.dayNs;
    var count = 0;
    for (like in likes.values()) {
      if (Principal.equal(like.from, caller) and like.createdAt >= dayStart) {
        count += 1;
      };
    };
    count;
  };

  func blockMap() : Map.Map<(Common.UserId, Common.UserId), Common.Timestamp> {
    let collected = Map.empty<(Common.UserId, Common.UserId), Common.Timestamp>();
    for ((key, block) in blocks.entries()) {
      collected.add(key, block.createdAt);
    };
    collected;
  };

  public query ({ caller }) func discoverCandidates(filter : Profile.DiscoverFilter) : async [Discover.Candidate] {
    requireDiscoverUser(caller);
    DiscoverLib.candidates(profiles, likes, passes, blockMap(), caller, filter, Time.now());
  };

  public shared ({ caller }) func likeUser(target : Common.UserId, kind : Discover.LikeKind) : async Discover.LikeResult {
    requireDiscoverUser(caller);
    if (Principal.equal(caller, target)) {
      Runtime.trap("You cannot like your own profile");
    };
    if (not profiles.containsKey(target)) {
      Runtime.trap("Profile not found");
    };
    if (DiscoverLib.hasLiked(likes, caller, target)) {
      // Idempotent: an existing like is reported as already liked.
      return #liked;
    };
    let now = Time.now();
    let premium = PremiumLib.isPremium(subscriptions, caller, now);
    switch (kind) {
      case (#superLike) {
        if (not PremiumLib.consumeSuperLike(superLikes, caller)) {
          return #limitReached;
        };
      };
      case (#like) {
        if (not premium and likesUsedToday(caller, now) >= PremiumLib.dailyLikeLimit) {
          return #limitReached;
        };
      };
    };
    DiscoverLib.recordLike(likes, caller, target, kind, now);
    // A mutual like creates a match.
    if (DiscoverLib.hasLiked(likes, target, caller)) {
      switch (MatchingLib.findBetween(matches, caller, target)) {
        case (?existing) { #matched({ matchId = existing.id }) };
        case (null) {
          let match_ = MatchingLib.create(matches, nextMatchId, caller, target, now);
          #matched({ matchId = match_.id });
        };
      };
    } else {
      #liked;
    };
  };

  public shared ({ caller }) func passUser(target : Common.UserId) : async () {
    requireDiscoverUser(caller);
    if (Principal.equal(caller, target)) {
      return;
    };
    DiscoverLib.recordPass(passes, caller, target, Time.now());
  };

  public query ({ caller }) func whoLikedMe() : async [Profile.ProfileView] {
    requireDiscoverUser(caller);
    let now = Time.now();
    let incoming = DiscoverLib.likesTo(likes, caller);
    incoming.filterMap(func (like) {
      switch (profiles.get(like.from)) {
        case (?profile) {
          ?ProfileLib.toView(profile, PremiumLib.isPremium(subscriptions, like.from, now), now);
        };
        case (null) { null };
      };
    });
  };
};
