import Common "common";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type NotificationKind = Common.NotificationKind;

  public type Notification = {
    id : Id;
    recipient : UserId;
    kind : NotificationKind;
    title : Text;
    body : Text;
    read : Bool;
    createdAt : Timestamp;
  };

  public type NotificationView = {
    id : Id;
    kind : NotificationKind;
    title : Text;
    body : Text;
    read : Bool;
    createdAt : Timestamp;
  };
};
