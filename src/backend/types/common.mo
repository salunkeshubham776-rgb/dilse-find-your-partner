import Storage "mo:caffeineai-object-storage/Storage";

module {
  // Signed Int nanoseconds from Time.now().
  public type Timestamp = Int;

  // Stable numeric identifier for app records.
  public type Id = Nat;

  // A user is identified by their Internet Identity principal.
  public type UserId = Principal;

  public type Gender = {
    #male;
    #female;
    #nonBinary;
    #other;
  };

  public type RelationshipPreference = {
    #longTerm;
    #friendship;
    #casualDating;
    #openToAll;
  };

  public type Photo = {
    blob : Storage.ExternalBlob;
    filename : Text;
    mimeType : Text;
  };

  public type PremiumPlan = {
    #monthly;
    #yearly;
  };

  public type PaymentStatus = {
    #pending;
    #succeeded;
    #failed;
    #cancelled;
  };

  public type ReportReason = {
    #fakeProfile;
    #harassment;
    #inappropriateContent;
    #spam;
    #underage;
    #other;
  };

  public type ReportStatus = {
    #open;
    #resolved;
    #dismissed;
  };

  public type NotificationKind = {
    #newMatch;
    #newMessage;
    #likedYou;
    #superLike;
    #subscriptionExpiry;
  };

  public type ApiError = {
    #unauthorized;
    #notFound;
    #invalidInput : Text;
    #underage;
    #banned;
    #likeLimitReached;
    #notPremium;
    #alreadyExists;
    #paymentFailed : Text;
  };
};
