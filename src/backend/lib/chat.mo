import Map "mo:core/Map";
import List "mo:core/List";
import Int "mo:core/Int";
import Nat "mo:core/Nat";
import Principal "mo:core/Principal";
import Common "../types/common";
import Chat "../types/chat";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type Message = Chat.Message;
  public type MessageContent = Chat.MessageContent;
  public type Block = Chat.Block;
  public type Report = Chat.Report;
  public type ReportInput = Chat.ReportInput;

  public func send(
    messages : Map.Map<Id, Message>,
    nextId : { var value : Id },
    matchId : Id,
    sender : UserId,
    content : MessageContent,
    now : Timestamp,
  ) : Message {
    let id = nextId.value;
    nextId.value := id + 1;
    let message : Message = {
      id;
      matchId;
      sender;
      content;
      createdAt = now;
    };
    messages.add(id, message);
    message;
  };

  public func history(messages : Map.Map<Id, Message>, matchId : Id) : [Message] {
    let collected = List.empty<Message>();
    for (message in messages.values()) {
      if (message.matchId == matchId) {
        collected.add(message);
      };
    };
    collected.toArray().sort(func (a, b) = Int.compare(a.createdAt, b.createdAt));
  };

  public func lastMessage(messages : Map.Map<Id, Message>, matchId : Id) : ?Message {
    var latest : ?Message = null;
    for (message in messages.values()) {
      if (message.matchId == matchId) {
        switch (latest) {
          case (?current) {
            if (message.createdAt > current.createdAt) {
              latest := ?message;
            };
          };
          case null {
            latest := ?message;
          };
        };
      };
    };
    latest;
  };

  public func isBlocked(blocks : Map.Map<(UserId, UserId), Block>, a : UserId, b : UserId) : Bool {
    blocks.containsKey((a, b)) or blocks.containsKey((b, a));
  };

  public func block(
    blocks : Map.Map<(UserId, UserId), Block>,
    caller : UserId,
    target : UserId,
    now : Timestamp,
  ) : () {
    if (caller == target) {
      return;
    };
    blocks.add((caller, target), { blocker = caller; blocked = target; createdAt = now });
  };

  public func unblock(
    blocks : Map.Map<(UserId, UserId), Block>,
    caller : UserId,
    target : UserId,
  ) : () {
    blocks.remove((caller, target));
  };

  public func createReport(
    reports : Map.Map<Id, Report>,
    nextId : { var value : Id },
    reporter : UserId,
    input : ReportInput,
    now : Timestamp,
  ) : Report {
    let id = nextId.value;
    nextId.value := id + 1;
    let report : Report = {
      id;
      reporter;
      reported = input.reported;
      reason = input.reason;
      details = input.details;
      status = #open;
      createdAt = now;
    };
    reports.add(id, report);
    report;
  };

  public func preview(content : MessageContent) : Text {
    switch (content) {
      case (#text(t)) { t };
      case (#image(_)) { "[Image]" };
    };
  };

  // Read state is tracked per (match, recipient) as the timestamp up to which
  // the recipient has seen messages. Kept separate from the shared Message type.
  public func markRead(
    readState : Map.Map<(Id, UserId), Timestamp>,
    matchId : Id,
    reader : UserId,
    now : Timestamp,
  ) : () {
    readState.add((matchId, reader), now);
  };

  public func unreadCount(
    messages : Map.Map<Id, Message>,
    readState : Map.Map<(Id, UserId), Timestamp>,
    matchId : Id,
    reader : UserId,
  ) : Nat {
    let seen = readState.get((matchId, reader));
    var count = 0;
    for (message in messages.values()) {
      if (message.matchId == matchId and not Principal.equal(message.sender, reader)) {
        let isUnread = switch (seen) {
          case (?ts) { message.createdAt > ts };
          case null { true };
        };
        if (isUnread) {
          count += 1;
        };
      };
    };
    count;
  };
};
