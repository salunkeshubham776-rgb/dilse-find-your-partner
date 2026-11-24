import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Common "../types/common";
import Profile "../types/profile";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Profile = Profile.Profile;
  public type ProfileView = Profile.ProfileView;
  public type OnboardingInput = Profile.OnboardingInput;
  public type ProfileUpdate = Profile.ProfileUpdate;

  // Nanoseconds in one UTC day.
  let nanosPerDay : Int = 86_400_000_000_000;

  // Age in whole years derived from a UTC epoch-day date of birth.
  public func ageFromDob(dob : Nat, now : Timestamp) : Nat {
    let nowDays = now / nanosPerDay;
    let dobDays = dob.toInt();
    if (nowDays <= dobDays) {
      return 0;
    };
    (nowDays - dobDays).toNat() / 365;
  };

  public func isAdult(dob : Nat, now : Timestamp) : Bool {
    ageFromDob(dob, now) >= 18;
  };

  public func toView(profile : Profile, premium : Bool, now : Timestamp) : ProfileView {
    {
      userId = profile.userId;
      displayName = profile.displayName;
      age = ageFromDob(profile.dateOfBirth, now);
      gender = profile.gender;
      city = profile.city;
      bio = profile.bio;
      interests = profile.interests;
      relationshipPreference = profile.relationshipPreference;
      photos = profile.photos;
      primaryPhotoIndex = profile.primaryPhotoIndex;
      verified = profile.verified;
      premium;
    };
  };

  public func create(
    profiles : Map.Map<UserId, Profile>,
    caller : UserId,
    input : OnboardingInput,
    now : Timestamp,
  ) : { #ok : Profile; #err : Common.ApiError } {
    if (profiles.containsKey(caller)) {
      return #err(#alreadyExists);
    };
    if (not isAdult(input.dateOfBirth, now)) {
      return #err(#underage);
    };
    if (input.displayName.size() == 0 or input.city.size() == 0) {
      return #err(#invalidInput("Display name and city are required"));
    };
    if (input.preferredAgeMin > input.preferredAgeMax) {
      return #err(#invalidInput("Preferred age range is invalid"));
    };
    let profile : Profile = {
      userId = caller;
      displayName = input.displayName;
      dateOfBirth = input.dateOfBirth;
      gender = input.gender;
      city = input.city;
      bio = input.bio;
      interests = input.interests;
      relationshipPreference = input.relationshipPreference;
      preferredGender = input.preferredGender;
      preferredAgeMin = input.preferredAgeMin;
      preferredAgeMax = input.preferredAgeMax;
      photos = [];
      primaryPhotoIndex = 0;
      verified = false;
      createdAt = now;
      updatedAt = now;
    };
    profiles.add(caller, profile);
    #ok(profile);
  };

  public func update(
    profiles : Map.Map<UserId, Profile>,
    caller : UserId,
    input : ProfileUpdate,
    now : Timestamp,
  ) : { #ok : Profile; #err : Common.ApiError } {
    let existing = switch (profiles.get(caller)) {
      case (?p) { p };
      case null { return #err(#notFound) };
    };
    if (input.displayName.size() == 0 or input.city.size() == 0) {
      return #err(#invalidInput("Display name and city are required"));
    };
    if (input.preferredAgeMin > input.preferredAgeMax) {
      return #err(#invalidInput("Preferred age range is invalid"));
    };
    let updated : Profile = {
      existing with
      displayName = input.displayName;
      gender = input.gender;
      city = input.city;
      bio = input.bio;
      interests = input.interests;
      relationshipPreference = input.relationshipPreference;
      preferredGender = input.preferredGender;
      preferredAgeMin = input.preferredAgeMin;
      preferredAgeMax = input.preferredAgeMax;
      updatedAt = now;
    };
    profiles.add(caller, updated);
    #ok(updated);
  };

  public func setPhotos(
    profiles : Map.Map<UserId, Profile>,
    caller : UserId,
    photos : [Common.Photo],
    primaryIndex : Nat,
    now : Timestamp,
  ) : { #ok : Profile; #err : Common.ApiError } {
    let existing = switch (profiles.get(caller)) {
      case (?p) { p };
      case null { return #err(#notFound) };
    };
    if (photos.size() > 6) {
      return #err(#invalidInput("A profile can have at most 6 photos"));
    };
    if (photos.size() > 0 and primaryIndex >= photos.size()) {
      return #err(#invalidInput("Primary photo index is out of range"));
    };
    let updated : Profile = {
      existing with
      photos;
      primaryPhotoIndex = primaryIndex;
      updatedAt = now;
    };
    profiles.add(caller, updated);
    #ok(updated);
  };

  public func get(profiles : Map.Map<UserId, Profile>, userId : UserId) : ?Profile {
    profiles.get(userId);
  };
};
