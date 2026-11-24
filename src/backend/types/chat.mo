import Common "common";
import Profile "profile";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type Photo = Common.Photo;
  public type ReportReason = Common.ReportReason;
  public type ReportStatus = Common.ReportStatus;

  public type MessageContent = {
    #text : Text;
    #image : Photo;
  };

  public type Message = {
    id : Id;
    matchId : Id;
    sender : UserId;
    content : MessageContent;
    createdAt : Timestamp;
  };

  public type ConversationView = {
    matchId : Id;
    other : Profile.ProfileView;
    lastMessagePreview : ?Text;
    lastMessageAt : ?Timestamp;
    unreadCount : Nat;
  };

  public type Block = {
    blocker : UserId;
    blocked : UserId;
    createdAt : Timestamp;
  };

  public type Report = {
    id : Id;
    reporter : UserId;
    reported : UserId;
    reason : ReportReason;
    details : Text;
    status : ReportStatus;
    createdAt : Timestamp;
  };

  public type ReportInput = {
    reported : UserId;
    reason : ReportReason;
    details : Text;
  };
};
