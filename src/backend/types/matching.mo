import Common "common";
import Profile "profile";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type ProfileView = Profile.ProfileView;

  public type Match = {
    id : Id;
    userA : UserId;
    userB : UserId;
    createdAt : Timestamp;
  };

  public type MatchView = {
    id : Id;
    other : ProfileView;
    createdAt : Timestamp;
    lastMessagePreview : ?Text;
    lastMessageAt : ?Timestamp;
    unreadCount : Nat;
  };
};
