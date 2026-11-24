import Map "mo:core/Map";
import Time "mo:core/Time";
import AccessControl "mo:caffeineai-authorization/access-control";
import Common "../types/common";
import Matching "../types/matching";
import Chat "../types/chat";
import ChatLib "../lib/chat";
import MatchingLib "../lib/matching";

// Moderation surface: blocking (which also drops the match from both feeds)
// and reporting into the admin complaints queue.
mixin (
  accessControlState : AccessControl.AccessControlState,
  matches : Map.Map<(Common.UserId, Common.UserId), Matching.Match>,
  blocks : Map.Map<(Common.UserId, Common.UserId), Chat.Block>,
  reports : Map.Map<Common.Id, Chat.Report>,
  nextReportId : { var value : Common.Id },
) {
  func requireRegistered(caller : Common.UserId) {
    ignore AccessControl.getUserRole(accessControlState, caller);
  };

  public shared ({ caller }) func blockUser(target : Common.UserId) : async () {
    requireRegistered(caller);
    if (caller == target) {
      return;
    };
    ChatLib.block(blocks, caller, target, Time.now());
    MatchingLib.removeBetween(matches, caller, target);
  };

  public shared ({ caller }) func unblockUser(target : Common.UserId) : async () {
    requireRegistered(caller);
    ChatLib.unblock(blocks, caller, target);
  };

  public shared ({ caller }) func reportUser(input : Chat.ReportInput) : async Chat.Report {
    requireRegistered(caller);
    ChatLib.createReport(reports, nextReportId, caller, input, Time.now());
  };
};
