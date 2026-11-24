import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Stripe "mo:caffeineai-stripe/stripe";
import OutCall "mo:caffeineai-http-outcalls/outcall";
import Common "../types/common";
import Premium "../types/premium";
import PremiumLib "../lib/premium";

mixin (
  accessControlState : AccessControl.AccessControlState,
  stripeState : Stripe.StripeState,
  subscriptions : Map.Map<Common.UserId, Premium.Subscription>,
  payments : Map.Map<Common.Id, Premium.Payment>,
  nextPaymentId : { var value : Common.Id },
  superLikes : Map.Map<Common.UserId, Nat>,
  boosts : Map.Map<Common.UserId, Premium.Boost>,
  transform : OutCall.Transform,
) {
  // Likes used today are not tracked in this domain; report zero.
  func likesUsedTodayFor(_user : Common.UserId) : Nat = 0;

  func requireSignedIn(caller : Principal) : () {
    if (caller.isAnonymous()) {
      Runtime.trap("Sign in to continue");
    };
  };

  public query ({ caller }) func getPremiumStatus() : async Premium.PremiumStatus {
    requireSignedIn(caller);
    PremiumLib.status(subscriptions, superLikes, boosts, likesUsedTodayFor(caller), caller, Time.now());
  };

  public query ({ caller }) func listPayments() : async [Premium.PaymentView] {
    requireSignedIn(caller);
    let mine = payments.values().filter(func p = p.userId == caller).toArray();
    let sorted = mine.sort(func (a, b) = if (a.createdAt > b.createdAt) { #less } else if (a.createdAt < b.createdAt) { #greater } else { #equal });
    sorted.map(func p = {
      id = p.id;
      plan = p.plan;
      superLikeCount = p.superLikeCount;
      amountCents = p.amountCents;
      currency = p.currency;
      status = p.status;
      createdAt = p.createdAt;
    });
  };

  public shared ({ caller }) func confirmCheckout(sessionId : Text) : async { #ok : Premium.SubscriptionView; #err : Common.ApiError } {
    requireSignedIn(caller);
    let configuration = switch (stripeState.configuration) {
      case (null) { return #err(#paymentFailed("Payments are not configured")) };
      case (?c) { c };
    };
    // Find the pending payment this session belongs to, owned by the caller.
    let payment = switch (payments.values().find(func p = p.stripeSessionId == sessionId and p.userId == caller)) {
      case (null) { return #err(#notFound) };
      case (?p) { p };
    };
    switch (payment.status) {
      case (#succeeded) {
        // Already activated — return the current subscription idempotently.
        switch (subscriptions.get(caller)) {
          case (?sub) { return #ok(PremiumLib.toView(sub)) };
          case (null) { return #err(#notFound) };
        };
      };
      case (#failed or #cancelled) { return #err(#paymentFailed("Payment did not complete")) };
      case (#pending) {};
    };
    let status = await Stripe.getSessionStatus(configuration, sessionId, transform);
    switch (status) {
      case (#failed({ error })) {
        PremiumLib.markPayment(payments, payment.id, #failed);
        #err(#paymentFailed(error));
      };
      case (#completed({ response; userPrincipal })) {
        // The session must belong to the caller who created it.
        switch (userPrincipal) {
          case (?p) {
            if (p != caller.toText()) {
              return #err(#unauthorized);
            };
          };
          case (null) {};
        };
        if (not response.contains(#text "\"payment_status\":\"paid\"")) {
          PremiumLib.markPayment(payments, payment.id, #failed);
          return #err(#paymentFailed("Payment was not completed"));
        };
        let now = Time.now();
        PremiumLib.markPayment(payments, payment.id, #succeeded);
        switch (payment.plan) {
          case (?plan) {
            let sub = PremiumLib.activate(subscriptions, caller, plan, now);
            #ok(PremiumLib.toView(sub));
          };
          case (null) {
            // Super-like pack: credit the purchased balance.
            PremiumLib.grantSuperLikes(superLikes, caller, payment.superLikeCount);
            switch (subscriptions.get(caller)) {
              case (?sub) { #ok(PremiumLib.toView(sub)) };
              case (null) {
                #err(#invalidInput("Purchase completed; no active subscription"));
              };
            };
          };
        };
      };
    };
  };

  public shared ({ caller }) func startProfileBoost() : async { #ok : Premium.Boost; #err : Common.ApiError } {
    requireSignedIn(caller);
    PremiumLib.startBoost(boosts, caller, Time.now());
  };
};
