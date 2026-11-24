import Common "common";
import Profile "profile";
import Chat "chat";
import Premium "premium";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type ProfileView = Profile.ProfileView;
  public type Report = Chat.Report;
  public type ReportStatus = Common.ReportStatus;
  public type PaymentView = Premium.PaymentView;
  public type SubscriptionView = Premium.SubscriptionView;

  public type AdminUserView = {
    userId : UserId;
    displayName : Text;
    city : Text;
    verified : Bool;
    banned : Bool;
    premium : Bool;
    createdAt : Timestamp;
  };

  public type RevenueSummary = {
    todayCents : Nat;
    monthCents : Nat;
    yearCents : Nat;
  };

  public type AdminOverview = {
    totalUsers : Nat;
    activeUsers : Nat;
    revenue : RevenueSummary;
  };

  public type Advertisement = {
    id : Id;
    title : Text;
    body : Text;
    active : Bool;
    createdAt : Timestamp;
  };

  public type AdvertisementInput = {
    title : Text;
    body : Text;
  };
};
