import Map "mo:core/Map";
import Common "../types/common";
import Profile "../types/profile";
import Chat "../types/chat";
import Premium "../types/premium";
import Admin "../types/admin";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type Advertisement = Admin.Advertisement;
  public type AdvertisementInput = Admin.AdvertisementInput;
  public type AdminUserView = Admin.AdminUserView;
  public type AdminOverview = Admin.AdminOverview;
  public type RevenueSummary = Admin.RevenueSummary;

  // Nanoseconds in one day.
  public let dayNs : Int = 86_400_000_000_000;

  // A user counts as active when their profile was updated within this window.
  public let activeWindowNs : Int = 2_592_000_000_000_000;

  public func createAd(
    ads : Map.Map<Id, Advertisement>,
    nextId : { var value : Id },
    input : AdvertisementInput,
    now : Timestamp,
  ) : Advertisement {
    let id = nextId.value;
    nextId.value := id + 1;
    let ad : Advertisement = {
      id;
      title = input.title;
      body = input.body;
      active = true;
      createdAt = now;
    };
    ads.add(id, ad);
    ad;
  };

  public func setAdActive(
    ads : Map.Map<Id, Advertisement>,
    adId : Id,
    active : Bool,
  ) : () {
    switch (ads.get(adId)) {
      case (?ad) { ads.add(adId, { ad with active }) };
      case null {};
    };
  };

  public func activeAds(ads : Map.Map<Id, Advertisement>) : [Advertisement] {
    ads.values().filter(func ad = ad.active).toArray();
  };

  public func allAds(ads : Map.Map<Id, Advertisement>) : [Advertisement] {
    ads.values().toArray();
  };

  // Start of the current UTC day, month and year, in nanoseconds.
  public func periodStarts(now : Timestamp) : { today : Timestamp; month : Timestamp; year : Timestamp } {
    let days = now / dayNs;
    let dayStart = days * dayNs;
    // 1970-01-01 was a Thursday; day 0 is the start of a 4-year cycle.
    let dayOfCycle = days % 1461;
    let yearIndex = days / 1461;
    let yearStartDay = yearIndex * 1461;
    let monthStartDay = yearStartDay + (dayOfCycle / 31) * 31;
    {
      today = dayStart;
      month = monthStartDay * dayNs;
      year = yearStartDay * dayNs;
    };
  };

  public func revenueSummary(payments : Map.Map<Id, Premium.Payment>, now : Timestamp) : RevenueSummary {
    let starts = periodStarts(now);
    var today = 0;
    var month = 0;
    var year = 0;
    for (payment in payments.values()) {
      if (payment.status == #succeeded) {
        if (payment.createdAt >= starts.today) { today += payment.amountCents };
        if (payment.createdAt >= starts.month) { month += payment.amountCents };
        if (payment.createdAt >= starts.year) { year += payment.amountCents };
      };
    };
    { todayCents = today; monthCents = month; yearCents = year };
  };

  public func overview(
    profiles : Map.Map<UserId, Profile.Profile>,
    payments : Map.Map<Id, Premium.Payment>,
    now : Timestamp,
  ) : AdminOverview {
    var total = 0;
    var active = 0;
    for (profile in profiles.values()) {
      total += 1;
      if (profile.updatedAt >= now - activeWindowNs) { active += 1 };
    };
    {
      totalUsers = total;
      activeUsers = active;
      revenue = revenueSummary(payments, now);
    };
  };

  public func userView(
    profile : Profile.Profile,
    banned : Bool,
    premium : Bool,
  ) : AdminUserView {
    {
      userId = profile.userId;
      displayName = profile.displayName;
      city = profile.city;
      verified = profile.verified;
      banned;
      premium;
      createdAt = profile.createdAt;
    };
  };

  public func matchesSearch(profile : Profile.Profile, search : ?Text) : Bool {
    switch (search) {
      case (null) { true };
      case (?raw) {
        let term = raw.toLower();
        if (term == "") {
          true;
        } else {
          profile.displayName.toLower().contains(#text term) or profile.city.toLower().contains(#text term);
        };
      };
    };
  };
};
