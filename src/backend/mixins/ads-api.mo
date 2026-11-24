import Map "mo:core/Map";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Admin "../types/admin";
import AdminLib "../lib/admin";

mixin (
  accessControlState : AccessControl.AccessControlState,
  ads : Map.Map<Common.Id, Admin.Advertisement>,
) {
  // Active ad placements are public so any visitor can render them.
  public query func listActiveAds() : async [Admin.Advertisement] {
    ignore accessControlState;
    AdminLib.activeAds(ads);
  };
};
