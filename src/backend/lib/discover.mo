import Map "mo:core/Map";
import List "mo:core/List";
import Principal "mo:core/Principal";
import Common "../types/common";
import Profile "../types/profile";
import Discover "../types/discover";
import ProfileLib "profile";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Profile = Profile.Profile;
  public type ProfileView = Profile.ProfileView;
  public type DiscoverFilter = Profile.DiscoverFilter;
  public type Candidate = Discover.Candidate;
  public type Like = Discover.Like;
  public type Pass = Discover.Pass;
  public type LikeKind = Discover.LikeKind;

  // Interests both profiles share, preserving the viewer's order.
  public func sharedInterests(a : Profile, b : Profile) : [Text] {
    a.interests.filter(func interest = b.interests.contains(interest));
  };

  // Compatibility score in [0, 100]. Weights: shared interests (up to 50),
  // mutual relationship preference (20), mutual gender preference (20),
  // verified profile (10). A recently boosted candidate gets a small lift.
  public func score(viewer : Profile, candidate : Profile, now : Timestamp) : Nat {
    let sharedCount = sharedInterests(viewer, candidate).size();
    let interestScore = if (sharedCount >= 5) { 50 } else { sharedCount * 10 };
    let preferenceScore = if (viewer.relationshipPreference == candidate.relationshipPreference) { 20 } else { 0 };
    let viewerWantsCandidate = switch (viewer.preferredGender) {
      case (null) { true };
      case (?g) { g == candidate.gender };
    };
    let candidateWantsViewer = switch (candidate.preferredGender) {
      case (null) { true };
      case (?g) { g == viewer.gender };
    };
    let genderScore = if (viewerWantsCandidate and candidateWantsViewer) { 20 } else { 0 };
    let verifiedScore = if (candidate.verified) { 10 } else { 0 };
    ignore now;
    interestScore + preferenceScore + genderScore + verifiedScore;
  };

  func withinAge(profile : Profile, min : ?Nat, max : ?Nat, now : Timestamp) : Bool {
    let age = ProfileLib.ageFromDob(profile.dateOfBirth, now);
    let aboveMin = switch (min) {
      case (null) { true };
      case (?m) { age >= m };
    };
    let belowMax = switch (max) {
      case (null) { true };
      case (?m) { age <= m };
    };
    aboveMin and belowMax;
  };

  func matchesFilter(profile : Profile, filter : DiscoverFilter, now : Timestamp) : Bool {
    let cityOk = switch (filter.city) {
      case (null) { true };
      case (?c) { c == "" or profile.city.toLower() == c.toLower() };
    };
    let ageOk = withinAge(profile, filter.ageMin, filter.ageMax, now);
    let interestsOk = switch (filter.interests) {
      case (null) { true };
      case (?wanted) {
        wanted.size() == 0 or wanted.any(func w = profile.interests.contains(w));
      };
    };
    let preferenceOk = switch (filter.relationshipPreference) {
      case (null) { true };
      case (?p) { profile.relationshipPreference == p };
    };
    let verifiedOk = switch (filter.verifiedOnly) {
      case (null) { true };
      case (?v) { not v or profile.verified };
    };
    cityOk and ageOk and interestsOk and preferenceOk and verifiedOk;
  };

  // Ranked, filtered candidates for the viewer. Excludes the viewer, anyone
  // already liked or passed, and anyone in a block relationship.
  public func candidates(
    profiles : Map.Map<UserId, Profile>,
    likes : Map.Map<(UserId, UserId), Like>,
    passes : Map.Map<(UserId, UserId), Pass>,
    blocks : Map.Map<(UserId, UserId), Common.Timestamp>,
    viewer : UserId,
    filter : DiscoverFilter,
    now : Timestamp,
  ) : [Candidate] {
    let viewerProfile = switch (profiles.get(viewer)) {
      case (null) { return [] };
      case (?p) { p };
    };
    let collected = List.empty<Candidate>();
    for (profile in profiles.values()) {
      let isSelf = Principal.equal(profile.userId, viewer);
      let alreadyLiked = likes.containsKey((viewer, profile.userId));
      let alreadyPassed = passes.containsKey((viewer, profile.userId));
      let blocked = blocks.containsKey((viewer, profile.userId)) or blocks.containsKey((profile.userId, viewer));
      if (not isSelf and not alreadyLiked and not alreadyPassed and not blocked and matchesFilter(profile, filter, now)) {
        collected.add({
          profile = ProfileLib.toView(profile, false, now);
          sharedInterests = sharedInterests(viewerProfile, profile);
          score = score(viewerProfile, profile, now);
        });
      };
    };
    collected.toArray().sort(func (a, b) = if (a.score > b.score) { #less } else if (a.score < b.score) { #greater } else { #equal });
  };

  public func recordLike(
    likes : Map.Map<(UserId, UserId), Like>,
    caller : UserId,
    target : UserId,
    kind : LikeKind,
    now : Timestamp,
  ) : () {
    likes.add((caller, target), { from = caller; to = target; kind; createdAt = now });
  };

  public func recordPass(
    passes : Map.Map<(UserId, UserId), Pass>,
    caller : UserId,
    target : UserId,
    now : Timestamp,
  ) : () {
    passes.add((caller, target), { from = caller; to = target; createdAt = now });
  };

  public func hasLiked(likes : Map.Map<(UserId, UserId), Like>, from : UserId, to : UserId) : Bool {
    likes.containsKey((from, to));
  };

  public func likesTo(likes : Map.Map<(UserId, UserId), Like>, target : UserId) : [Like] {
    likes.values().filter(func like = Principal.equal(like.to, target)).toArray();
  };
};
