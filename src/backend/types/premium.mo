import Common "common";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type PremiumPlan = Common.PremiumPlan;
  public type PaymentStatus = Common.PaymentStatus;

  public type Subscription = {
    userId : UserId;
    plan : PremiumPlan;
    startedAt : Timestamp;
    expiresAt : Timestamp;
    active : Bool;
  };

  public type SubscriptionView = {
    plan : PremiumPlan;
    startedAt : Timestamp;
    expiresAt : Timestamp;
    active : Bool;
  };

  public type Payment = {
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

  public type PaymentView = {
    id : Id;
    plan : ?PremiumPlan;
    superLikeCount : Nat;
    amountCents : Nat;
    currency : Text;
    status : PaymentStatus;
    createdAt : Timestamp;
  };

  public type Boost = {
    userId : UserId;
    startedAt : Timestamp;
    expiresAt : Timestamp;
  };

  public type PremiumStatus = {
    premium : Bool;
    subscription : ?SubscriptionView;
    superLikes : Nat;
    boostAvailable : Bool;
    likesUsedToday : Nat;
    dailyLikeLimit : Nat;
  };
};
