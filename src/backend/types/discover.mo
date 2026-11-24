import Common "common";
import Profile "profile";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type ProfileView = Profile.ProfileView;
  public type DiscoverFilter = Profile.DiscoverFilter;

  public type LikeKind = {
    #like;
    #superLike;
  };

  public type Like = {
    from : UserId;
    to : UserId;
    kind : LikeKind;
    createdAt : Timestamp;
  };

  public type Pass = {
    from : UserId;
    to : UserId;
    createdAt : Timestamp;
  };

  public type Candidate = {
    profile : ProfileView;
    sharedInterests : [Text];
    score : Nat;
  };

  public type LikeResult = {
    #liked;
    #matched : { matchId : Common.Id };
    #limitReached;
  };
};
