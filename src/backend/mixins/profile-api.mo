import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Profile "../types/profile";
import Premium "../types/premium";
import ProfileLib "../lib/profile";
import PremiumLib "../lib/premium";

mixin (
  accessControlState : AccessControl.AccessControlState,
  profiles : Map.Map<Common.UserId, Profile.Profile>,
  subscriptions : Map.Map<Common.UserId, Premium.Subscription>,
) {
  func requireProfileUser(caller : Common.UserId) {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only users can perform this action");
    };
  };

  func viewOf(userId : Common.UserId, now : Common.Timestamp) : ?Profile.ProfileView {
    switch (profiles.get(userId)) {
      case (?p) {
        ?ProfileLib.toView(p, PremiumLib.isPremium(subscriptions, userId, now), now);
      };
      case null { null };
    };
  };

  public query ({ caller }) func getCallerProfile() : async ?Profile.ProfileView {
    requireProfileUser(caller);
    viewOf(caller, Time.now());
  };

  public query ({ caller }) func getProfile(userId : Common.UserId) : async ?Profile.ProfileView {
    requireProfileUser(caller);
    viewOf(userId, Time.now());
  };

  public shared ({ caller }) func completeOnboarding(input : Profile.OnboardingInput) : async { #ok : Profile.ProfileView; #err : Common.ApiError } {
    requireProfileUser(caller);
    let now = Time.now();
    switch (ProfileLib.create(profiles, caller, input, now)) {
      case (#ok(p)) {
        #ok(ProfileLib.toView(p, PremiumLib.isPremium(subscriptions, caller, now), now));
      };
      case (#err(e)) { #err(e) };
    };
  };

  public shared ({ caller }) func updateProfile(input : Profile.ProfileUpdate) : async { #ok : Profile.ProfileView; #err : Common.ApiError } {
    requireProfileUser(caller);
    let now = Time.now();
    switch (ProfileLib.update(profiles, caller, input, now)) {
      case (#ok(p)) {
        #ok(ProfileLib.toView(p, PremiumLib.isPremium(subscriptions, caller, now), now));
      };
      case (#err(e)) { #err(e) };
    };
  };

  public shared ({ caller }) func setProfilePhotos(photos : [Common.Photo], primaryIndex : Nat) : async { #ok : Profile.ProfileView; #err : Common.ApiError } {
    requireProfileUser(caller);
    let now = Time.now();
    switch (ProfileLib.setPhotos(profiles, caller, photos, primaryIndex, now)) {
      case (#ok(p)) {
        #ok(ProfileLib.toView(p, PremiumLib.isPremium(subscriptions, caller, now), now));
      };
      case (#err(e)) { #err(e) };
    };
  };
};
