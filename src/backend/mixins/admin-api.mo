import Map "mo:core/Map";
import Runtime "mo:core/Runtime";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Profile "../types/profile";
import Chat "../types/chat";
import Premium "../types/premium";
import Admin "../types/admin";
import AdminLib "../lib/admin";
import PremiumLib "../lib/premium";

mixin (
  accessControlState : AccessControl.AccessControlState,
  profiles : Map.Map<Common.UserId, Profile.Profile>,
  bans : Map.Map<Common.UserId, Common.Timestamp>,
  reports : Map.Map<Common.Id, Chat.Report>,
  payments : Map.Map<Common.Id, Premium.Payment>,
  subscriptions : Map.Map<Common.UserId, Premium.Subscription>,
  ads : Map.Map<Common.Id, Admin.Advertisement>,
  nextAdId : { var value : Common.Id },
) {
  // AccessControl.isAdmin traps for unregistered callers, so resolve the role
  // defensively and treat anything that is not an admin as unauthorized.
  func requireAdmin(caller : Common.UserId) {
    let isAdmin = switch (accessControlState.userRoles.get(caller)) {
      case (?#admin) { true };
      case (_) { false };
    };
    if (not isAdmin) {
      Runtime.trap("Unauthorized: Only admins can perform this action");
    };
  };

  public query ({ caller }) func adminOverview() : async Admin.AdminOverview {
    requireAdmin(caller);
    AdminLib.overview(profiles, payments, Time.now());
  };

  public query ({ caller }) func adminListUsers(search : ?Text) : async [Admin.AdminUserView] {
    requireAdmin(caller);
    let now = Time.now();
    profiles.values()
      .filter(func p = AdminLib.matchesSearch(p, search))
      .map(func p = AdminLib.userView(p, bans.containsKey(p.userId), PremiumLib.isPremium(subscriptions, p.userId, now)))
      .toArray();
  };

  public shared ({ caller }) func adminSetVerified(userId : Common.UserId, verified : Bool) : async () {
    requireAdmin(caller);
    switch (profiles.get(userId)) {
      case (?p) { profiles.add(userId, { p with verified }) };
      case (null) { Runtime.trap("User not found") };
    };
  };

  public shared ({ caller }) func adminSetBanned(userId : Common.UserId, banned : Bool) : async () {
    requireAdmin(caller);
    if (banned) {
      bans.add(userId, Time.now());
    } else {
      bans.remove(userId);
    };
  };

  public query ({ caller }) func adminListReports() : async [Chat.Report] {
    requireAdmin(caller);
    reports.values().toArray();
  };

  public shared ({ caller }) func adminResolveReport(reportId : Common.Id, status : Common.ReportStatus) : async () {
    requireAdmin(caller);
    switch (reports.get(reportId)) {
      case (?report) { reports.add(reportId, { report with status }) };
      case (null) { Runtime.trap("Report not found") };
    };
  };

  public query ({ caller }) func adminListPayments() : async [Premium.PaymentView] {
    requireAdmin(caller);
    payments.values().map(func p = PremiumLib.paymentView(p)).toArray();
  };

  public query ({ caller }) func adminListSubscriptions() : async [Premium.SubscriptionView] {
    requireAdmin(caller);
    subscriptions.values().map(func s = PremiumLib.toView(s)).toArray();
  };

  public query ({ caller }) func adminListAds() : async [Admin.Advertisement] {
    requireAdmin(caller);
    AdminLib.allAds(ads);
  };

  public shared ({ caller }) func adminCreateAd(input : Admin.AdvertisementInput) : async Admin.Advertisement {
    requireAdmin(caller);
    AdminLib.createAd(ads, nextAdId, input, Time.now());
  };

  public shared ({ caller }) func adminSetAdActive(adId : Common.Id, active : Bool) : async () {
    requireAdmin(caller);
    AdminLib.setAdActive(ads, adId, active);
  };
};
