import Common "common";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Gender = Common.Gender;
  public type RelationshipPreference = Common.RelationshipPreference;
  public type Photo = Common.Photo;

  // Stored profile. `dateOfBirth` is a UTC epoch-day count (days since 1970-01-01).
  public type Profile = {
    userId : UserId;
    displayName : Text;
    dateOfBirth : Nat;
    gender : Gender;
    city : Text;
    bio : Text;
    interests : [Text];
    relationshipPreference : RelationshipPreference;
    preferredGender : ?Gender;
    preferredAgeMin : Nat;
    preferredAgeMax : Nat;
    photos : [Photo];
    primaryPhotoIndex : Nat;
    verified : Bool;
    createdAt : Timestamp;
    updatedAt : Timestamp;
  };

  // Public projection shown to other users. Never includes phone or exact location.
  public type ProfileView = {
    userId : UserId;
    displayName : Text;
    age : Nat;
    gender : Gender;
    city : Text;
    bio : Text;
    interests : [Text];
    relationshipPreference : RelationshipPreference;
    photos : [Photo];
    primaryPhotoIndex : Nat;
    verified : Bool;
    premium : Bool;
  };

  public type OnboardingInput = {
    displayName : Text;
    dateOfBirth : Nat;
    gender : Gender;
    city : Text;
    bio : Text;
    interests : [Text];
    relationshipPreference : RelationshipPreference;
    preferredGender : ?Gender;
    preferredAgeMin : Nat;
    preferredAgeMax : Nat;
  };

  public type ProfileUpdate = {
    displayName : Text;
    gender : Gender;
    city : Text;
    bio : Text;
    interests : [Text];
    relationshipPreference : RelationshipPreference;
    preferredGender : ?Gender;
    preferredAgeMin : Nat;
    preferredAgeMax : Nat;
  };

  public type DiscoverFilter = {
    city : ?Text;
    ageMin : ?Nat;
    ageMax : ?Nat;
    interests : ?[Text];
    relationshipPreference : ?RelationshipPreference;
    verifiedOnly : ?Bool;
  };
};
