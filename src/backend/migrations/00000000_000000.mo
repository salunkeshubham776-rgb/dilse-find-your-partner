import Map "mo:core/Map";
import Principal "mo:core/Principal";
import AccessControl "mo:caffeineai-authorization/access-control";
import Storage "mo:caffeineai-object-storage/Storage";

module {
  // ---- Inlined app types (migrations must be self-contained) ----

  type UserId = Principal;
  type Timestamp = Int;
  type Id = Nat;

  type Gender = { #male; #female; #nonBinary; #other };

  type RelationshipPreference = { #longTerm; #friendship; #casualDating; #openToAll };

  type Photo = {
    blob : Storage.ExternalBlob;
    filename : Text;
    mimeType : Text;
  };

  type Profile = {
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

  type LikeKind = { #like; #superLike };

  type Like = {
    from : UserId;
    to : UserId;
    kind : LikeKind;
    createdAt : Timestamp;
  };

  type Pass = {
    from : UserId;
    to : UserId;
    createdAt : Timestamp;
  };

  type Match = {
    id : Id;
    userA : UserId;
    userB : UserId;
    createdAt : Timestamp;
  };

  type MessageContent = { #text : Text; #image : Photo };

  type Message = {
    id : Id;
    matchId : Id;
    sender : UserId;
    content : MessageContent;
    createdAt : Timestamp;
  };

  type Block = {
    blocker : UserId;
    blocked : UserId;
    createdAt : Timestamp;
  };

  type ReportReason = {
    #fakeProfile;
    #harassment;
    #inappropriateContent;
    #spam;
    #underage;
    #other;
  };

  type ReportStatus = { #open; #resolved; #dismissed };

  type Report = {
    id : Id;
    reporter : UserId;
    reported : UserId;
    reason : ReportReason;
    details : Text;
    status : ReportStatus;
    createdAt : Timestamp;
  };

  type NotificationKind = {
    #newMatch;
    #newMessage;
    #likedYou;
    #superLike;
    #subscriptionExpiry;
  };

  type Notification = {
    id : Id;
    recipient : UserId;
    kind : NotificationKind;
    title : Text;
    body : Text;
    read : Bool;
    createdAt : Timestamp;
  };

  type PremiumPlan = { #monthly; #yearly };

  type PaymentStatus = { #pending; #succeeded; #failed; #cancelled };

  type Subscription = {
    userId : UserId;
    plan : PremiumPlan;
    startedAt : Timestamp;
    expiresAt : Timestamp;
    active : Bool;
  };

  type Payment = {
    id : Id;
    userId : UserId;
    plan : ?PremiumPlan;
    superLikeCount : Nat;
    amountCents : Nat;
    currency : Text;
    status : PaymentStatus;
    stripeSessionId : Text;
    createdAt : Timestamp;
  };

  type Boost = {
    userId : UserId;
    startedAt : Timestamp;
    expiresAt : Timestamp;
  };

  type Advertisement = {
    id : Id;
    title : Text;
    body : Text;
    active : Bool;
    createdAt : Timestamp;
  };

  type StripeConfiguration = {
    secretKey : Text;
    allowedCountries : [Text];
  };

  type StripeState = {
    var configuration : ?StripeConfiguration;
  };

  type Counter = { var value : Id };

  // ---- Actor shape ----

  public type OldActor = {};

  public type NewActor = {
    accessControlState : AccessControl.AccessControlState;
    stripeState : StripeState;
    profiles : Map.Map<UserId, Profile>;
    likes : Map.Map<(UserId, UserId), Like>;
    passes : Map.Map<(UserId, UserId), Pass>;
    matches : Map.Map<(UserId, UserId), Match>;
    messages : Map.Map<Id, Message>;
    blocks : Map.Map<(UserId, UserId), Block>;
    reports : Map.Map<Id, Report>;
    readState : Map.Map<(Id, UserId), Timestamp>;
    notifications : Map.Map<Id, Notification>;
    verifiedEmails : Map.Map<Principal, Text>;
    subscriptions : Map.Map<UserId, Subscription>;
    payments : Map.Map<Id, Payment>;
    superLikes : Map.Map<UserId, Nat>;
    boosts : Map.Map<UserId, Boost>;
    bans : Map.Map<UserId, Timestamp>;
    ads : Map.Map<Id, Advertisement>;
    nextMatchId : Counter;
    nextMessageId : Counter;
    nextReportId : Counter;
    nextPaymentId : Counter;
    nextNotificationId : Counter;
    nextAdId : Counter;
  };

  public func migration(_ : OldActor) : NewActor {
    {
      accessControlState = AccessControl.initState();
      stripeState = { var configuration = null };
      profiles = Map.empty();
      likes = Map.empty();
      passes = Map.empty();
      matches = Map.empty();
      messages = Map.empty();
      blocks = Map.empty();
      reports = Map.empty();
      readState = Map.empty();
      notifications = Map.empty();
      verifiedEmails = Map.empty();
      subscriptions = Map.empty();
      payments = Map.empty();
      superLikes = Map.empty();
      boosts = Map.empty();
      bans = Map.empty();
      ads = Map.empty();
      nextMatchId = { var value = 0 };
      nextMessageId = { var value = 0 };
      nextReportId = { var value = 0 };
      nextPaymentId = { var value = 0 };
      nextNotificationId = { var value = 0 };
      nextAdId = { var value = 0 };
    };
  };
};
