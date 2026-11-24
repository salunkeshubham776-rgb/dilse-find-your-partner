import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Common "../types/common";
import Premium "../types/premium";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type Subscription = Premium.Subscription;
  public type Payment = Premium.Payment;
  public type PremiumPlan = Common.PremiumPlan;
  public type PremiumStatus = Premium.PremiumStatus;
  public type Boost = Premium.Boost;

  public let dailyLikeLimit : Nat = 20;

  // Nanoseconds in one day.
  public let dayNs : Int = 86_400_000_000_000;

  // A profile boost lasts 30 minutes.
  public let boostDurationNs : Int = 1_800_000_000_000;

  public func planDurationNs(plan : PremiumPlan) : Int {
    switch (plan) {
      case (#monthly) { 30 * dayNs };
      case (#yearly) { 365 * dayNs };
    };
  };

  public func toView(sub : Subscription) : Premium.SubscriptionView {
    {
      plan = sub.plan;
      startedAt = sub.startedAt;
      expiresAt = sub.expiresAt;
      active = sub.active;
    };
  };

  public func paymentView(payment : Payment) : Premium.PaymentView {
    {
      id = payment.id;
      plan = payment.plan;
      superLikeCount = payment.superLikeCount;
      amountCents = payment.amountCents;
      currency = payment.currency;
      status = payment.status;
      createdAt = payment.createdAt;
    };
  };

  public func isPremium(subscriptions : Map.Map<UserId, Subscription>, user : UserId, now : Timestamp) : Bool {
    switch (subscriptions.get(user)) {
      case (null) { false };
      case (?sub) { sub.active and sub.expiresAt > now };
    };
  };

  public func activate(
    subscriptions : Map.Map<UserId, Subscription>,
    user : UserId,
    plan : PremiumPlan,
    now : Timestamp,
  ) : Subscription {
    // Extend from the current expiry when the subscription is still running,
    // otherwise start fresh from now.
    let base = switch (subscriptions.get(user)) {
      case (?sub) { if (sub.active and sub.expiresAt > now) { sub.expiresAt } else { now } };
      case (null) { now };
    };
    let sub : Subscription = {
      userId = user;
      plan;
      startedAt = now;
      expiresAt = base + planDurationNs(plan);
      active = true;
    };
    subscriptions.add(user, sub);
    sub;
  };

  public func recordPayment(
    payments : Map.Map<Id, Payment>,
    nextId : { var value : Id },
    user : UserId,
    plan : ?PremiumPlan,
    superLikeCount : Nat,
    amountCents : Nat,
    currency : Text,
    sessionId : Text,
    now : Timestamp,
  ) : Payment {
    let id = nextId.value;
    nextId.value := id + 1;
    let payment : Payment = {
      id;
      userId = user;
      plan;
      superLikeCount;
      amountCents;
      currency;
      status = #pending;
      stripeSessionId = sessionId;
      createdAt = now;
    };
    payments.add(id, payment);
    payment;
  };

  public func markPayment(
    payments : Map.Map<Id, Payment>,
    paymentId : Id,
    status : Common.PaymentStatus,
  ) : () {
    switch (payments.get(paymentId)) {
      case (null) {};
      case (?payment) {
        payments.add(paymentId, { payment with status });
      };
    };
  };

  public func status(
    subscriptions : Map.Map<UserId, Subscription>,
    superLikes : Map.Map<UserId, Nat>,
    boosts : Map.Map<UserId, Boost>,
    likesUsedToday : Nat,
    user : UserId,
    now : Timestamp,
  ) : PremiumStatus {
    let premium = isPremium(subscriptions, user, now);
    let subscription = switch (subscriptions.get(user)) {
      case (null) { null };
      case (?sub) { ?toView(sub) };
    };
    let boostAvailable = switch (boosts.get(user)) {
      case (null) { true };
      case (?boost) { boost.startedAt + dayNs <= now };
    };
    {
      premium;
      subscription;
      superLikes = superLikes.get(user) ?? 0;
      boostAvailable;
      likesUsedToday;
      dailyLikeLimit;
    };
  };

  public func grantSuperLikes(
    superLikes : Map.Map<UserId, Nat>,
    user : UserId,
    count : Nat,
  ) : () {
    let current = superLikes.get(user) ?? 0;
    superLikes.add(user, current + count);
  };

  public func consumeSuperLike(superLikes : Map.Map<UserId, Nat>, user : UserId) : Bool {
    let current = superLikes.get(user) ?? 0;
    if (current == 0) {
      false;
    } else {
      superLikes.add(user, current - 1);
      true;
    };
  };

  public func startBoost(
    boosts : Map.Map<UserId, Boost>,
    user : UserId,
    now : Timestamp,
  ) : { #ok : Boost; #err : Common.ApiError } {
    switch (boosts.get(user)) {
      case (?boost) {
        if (boost.startedAt + dayNs > now) {
          return #err(#alreadyExists);
        };
      };
      case (null) {};
    };
    let boost : Boost = {
      userId = user;
      startedAt = now;
      expiresAt = now + boostDurationNs;
    };
    boosts.add(user, boost);
    #ok(boost);
  };
};
