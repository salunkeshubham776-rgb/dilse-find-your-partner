import Map "mo:core/Map";
import Principal "mo:core/Principal";
import AccessControl "mo:caffeineai-authorization/access-control";
import MixinAuthorization "mo:caffeineai-authorization/MixinAuthorization";
import MixinObjectStorage "mo:caffeineai-object-storage/Mixin";
import Stripe "mo:caffeineai-stripe/stripe";
import MixinStripe "mo:caffeineai-stripe/MixinStripe";
import Expose "mo:caffeineai-oql/Expose";
import Entity "mo:caffeineai-oql/Entity";
import MapEntity "mo:caffeineai-oql/MapEntity";
import RecordValue "mo:caffeineai-oql/RecordValue";
import NatValue "mo:caffeineai-oql/NatValue";
import IntValue "mo:caffeineai-oql/IntValue";
import TextValue "mo:caffeineai-oql/TextValue";
import PrincipalValue "mo:caffeineai-oql/PrincipalValue";
import BoolValue "mo:caffeineai-oql/BoolValue";

import GenderValue "types/GenderValue";
import RelationshipPreferenceValue "types/RelationshipPreferenceValue";
import LikeKindValue "types/LikeKindValue";
import MessageContentValue "types/MessageContentValue";
import ReportReasonValue "types/ReportReasonValue";
import ReportStatusValue "types/ReportStatusValue";
import PremiumPlanValue "types/PremiumPlanValue";
import PaymentStatusValue "types/PaymentStatusValue";
import NotificationKindValue "types/NotificationKindValue";

import Common "types/common";
import Profile "types/profile";
import Discover "types/discover";
import Matching "types/matching";
import Chat "types/chat";
import Premium "types/premium";
import Notifications "types/notifications";
import Admin "types/admin";

import ProfileApi "mixins/profile-api";
import DiscoverApi "mixins/discover-api";
import MatchingApi "mixins/matching-api";
import ChatApi "mixins/chat-api";
import PremiumApi "mixins/premium-api";
import NotificationsApi "mixins/notifications-api";
import AdminApi "mixins/admin-api";
import AdsApi "mixins/ads-api";
import ApiDocMixin "mixins/api-doc";

actor {
  let accessControlState : AccessControl.AccessControlState;
  include MixinAuthorization(accessControlState, null);

  include MixinObjectStorage();

  let stripeState : Stripe.StripeState;
  include MixinStripe(accessControlState, stripeState);

  // Core entities
  let profiles : Map.Map<Common.UserId, Profile.Profile>;
  let likes : Map.Map<(Common.UserId, Common.UserId), Discover.Like>;
  let passes : Map.Map<(Common.UserId, Common.UserId), Discover.Pass>;
  let matches : Map.Map<(Common.UserId, Common.UserId), Matching.Match>;
  let messages : Map.Map<Common.Id, Chat.Message>;
  let blocks : Map.Map<(Common.UserId, Common.UserId), Chat.Block>;
  let reports : Map.Map<Common.Id, Chat.Report>;
  let readState : Map.Map<(Common.Id, Common.UserId), Common.Timestamp>;
  let notifications : Map.Map<Common.Id, Notifications.Notification>;
  let verifiedEmails : Map.Map<Principal, Text>;

  // Premium & payments
  let subscriptions : Map.Map<Common.UserId, Premium.Subscription>;
  let payments : Map.Map<Common.Id, Premium.Payment>;
  let superLikes : Map.Map<Common.UserId, Nat>;
  let boosts : Map.Map<Common.UserId, Premium.Boost>;

  // Admin
  let bans : Map.Map<Common.UserId, Common.Timestamp>;
  let ads : Map.Map<Common.Id, Admin.Advertisement>;

  // Counters
  let nextMatchId : { var value : Common.Id };
  let nextMessageId : { var value : Common.Id };
  let nextReportId : { var value : Common.Id };
  let nextPaymentId : { var value : Common.Id };
  let nextNotificationId : { var value : Common.Id };
  let nextAdId : { var value : Common.Id };

  include ProfileApi(accessControlState, profiles, subscriptions);
  include DiscoverApi(accessControlState, profiles, likes, passes, blocks, matches, nextMatchId, subscriptions, superLikes);
  include MatchingApi(accessControlState, profiles, matches, messages, blocks, subscriptions);
  include ChatApi(accessControlState, profiles, matches, messages, nextMessageId, blocks, reports, nextReportId, readState, subscriptions);
  include PremiumApi(accessControlState, stripeState, subscriptions, payments, nextPaymentId, superLikes, boosts, transform);
  include NotificationsApi(accessControlState, notifications, nextNotificationId);
  include AdminApi(accessControlState, profiles, bans, reports, payments, subscriptions, ads, nextAdId);
  include AdsApi(accessControlState, ads);
  include ApiDocMixin();

  transient let samplePrincipal = Principal.fromText("aaaaa-aa");

  include Expose({
    entities = [
      profiles.toEntityManual("profile", "Profile", "userId")
        .sample({
          userId = samplePrincipal;
          displayName = "";
          dateOfBirth = 0;
          gender = #other;
          city = "";
          bio = "";
          interests = [];
          relationshipPreference = #openToAll;
          preferredGender = ?#other;
          preferredAgeMin = 18;
          preferredAgeMax = 99;
          photos = [];
          primaryPhotoIndex = 0;
          verified = false;
          createdAt = 0;
          updatedAt = 0;
        })
        .payload("userId", func p = p.userId)
        .payload("displayName", func p = p.displayName)
        .payload("dateOfBirth", func p = p.dateOfBirth)
        .payload("gender", func p = p.gender)
        .payload("city", func p = p.city)
        .payload("bio", func p = p.bio)
        .payload("interestCount", func p = p.interests.size())
        .payload("relationshipPreference", func p = p.relationshipPreference)
        .payload("preferredGender", func p = p.preferredGender)
        .payload("preferredAgeMin", func p = p.preferredAgeMin)
        .payload("preferredAgeMax", func p = p.preferredAgeMax)
        .payload("photoCount", func p = p.photos.size())
        .payload("verified", func p = p.verified)
        .payload("createdAt", func p = p.createdAt)
        .payload("updatedAt", func p = p.updatedAt)
        .ownedBy("userId")
        .controllerOrScoped()
        .build(),
      likes.toEntity("like", "Like", "from")
        .sample({
          from = samplePrincipal;
          to = samplePrincipal;
          kind = #like;
          createdAt = 0;
        })
        .ownedBy("from")
        .controllerOrScoped()
        .build(),
      passes.toEntity("pass", "Pass", "from")
        .sample({
          from = samplePrincipal;
          to = samplePrincipal;
          createdAt = 0;
        })
        .ownedBy("from")
        .controllerOrScoped()
        .build(),
      blocks.toEntity("block", "Block", "blocker")
        .sample({
          blocker = samplePrincipal;
          blocked = samplePrincipal;
          createdAt = 0;
        })
        .ownedBy("blocker")
        .controllerOrScoped()
        .build(),
      matches.toEntity("match", "Match", "id")
        .sample({
          id = 0;
          userA = samplePrincipal;
          userB = samplePrincipal;
          createdAt = 0;
        })
        .ownedBy("userA")
        .controllerOrScoped()
        .build(),
      messages.toEntity("message", "Message", "id")
        .sample({
          id = 0;
          matchId = 0;
          sender = samplePrincipal;
          content = #text("");
          createdAt = 0;
        })
        .ownedBy("sender")
        .scopedPerUser()
        .build(),
      reports.toEntity("report", "Report", "id")
        .sample({
          id = 0;
          reporter = samplePrincipal;
          reported = samplePrincipal;
          reason = #other;
          details = "";
          status = #open;
          createdAt = 0;
        })
        .controllerOnly()
        .build(),
      ads.toEntity("advertisement", "Advertisement", "id")
        .sample({
          id = 0;
          title = "";
          body = "";
          active = false;
          createdAt = 0;
        })
        .public_()
        .build(),
      boosts.toEntity("boost", "Boost", "userId")
        .sample({
          userId = samplePrincipal;
          startedAt = 0;
          expiresAt = 0;
        })
        .ownedBy("userId")
        .controllerOrScoped()
        .build(),
      subscriptions.toEntity("subscription", "Subscription", "userId")
        .sample({
          userId = samplePrincipal;
          plan = #monthly;
          startedAt = 0;
          expiresAt = 0;
          active = false;
        })
        .ownedBy("userId")
        .controllerOrScoped()
        .build(),
      payments.toEntity("payment", "Payment", "id")
        .sample({
          id = 0;
          userId = samplePrincipal;
          plan = ?#monthly;
          superLikeCount = 0;
          amountCents = 0;
          currency = "usd";
          status = #pending;
          stripeSessionId = "";
          createdAt = 0;
        })
        .ownedBy("userId")
        .controllerOrScoped()
        .build(),
      notifications.toEntity("notification", "Notification", "id")
        .sample({
          id = 0;
          recipient = samplePrincipal;
          kind = #newMatch;
          title = "";
          body = "";
          read = false;
          createdAt = 0;
        })
        .ownedBy("recipient")
        .controllerOrScoped()
        .build(),
    ];
  });
};
