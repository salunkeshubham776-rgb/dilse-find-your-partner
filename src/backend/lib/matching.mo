import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Common "../types/common";
import Matching "../types/matching";

module {
  public type UserId = Common.UserId;
  public type Timestamp = Common.Timestamp;
  public type Id = Common.Id;
  public type Match = Matching.Match;

  // Canonical, order-independent key for a pair of users.
  public func key(a : UserId, b : UserId) : (UserId, UserId) {
    if (Principal.compare(a, b) == #less) {
      (a, b);
    } else {
      (b, a);
    };
  };

  public func findBetween(
    matches : Map.Map<(UserId, UserId), Match>,
    a : UserId,
    b : UserId,
  ) : ?Match {
    matches.get(key(a, b));
  };

  public func create(
    matches : Map.Map<(UserId, UserId), Match>,
    nextId : { var value : Id },
    a : UserId,
    b : UserId,
    now : Timestamp,
  ) : Match {
    let id = nextId.value;
    nextId.value := id + 1;
    let match : Match = {
      id;
      userA = a;
      userB = b;
      createdAt = now;
    };
    matches.add(key(a, b), match);
    match;
  };

  public func removeBetween(
    matches : Map.Map<(UserId, UserId), Match>,
    a : UserId,
    b : UserId,
  ) : () {
    matches.remove(key(a, b));
  };

  public func forUser(matches : Map.Map<(UserId, UserId), Match>, user : UserId) : [Match] {
    matches.values().filter(func m = Principal.equal(m.userA, user) or Principal.equal(m.userB, user)).toArray();
  };
};
