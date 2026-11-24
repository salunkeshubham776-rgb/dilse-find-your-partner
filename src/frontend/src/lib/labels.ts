import {
  Gender,
  NotificationKindEnum,
  PaymentStatusEnum,
  PremiumPlanEnum,
  RelationshipPreferenceEnum,
  ReportReasonEnum,
  ReportStatusEnum,
} from "@/types";

export const GENDER_LABELS: Record<Gender, string> = {
  [Gender.female]: "Woman",
  [Gender.male]: "Man",
  [Gender.nonBinary]: "Non-binary",
  [Gender.other]: "Other",
};

export const RELATIONSHIP_LABELS: Record<RelationshipPreferenceEnum, string> = {
  [RelationshipPreferenceEnum.longTerm]: "Long-term",
  [RelationshipPreferenceEnum.casualDating]: "Casual dating",
  [RelationshipPreferenceEnum.friendship]: "Friendship",
  [RelationshipPreferenceEnum.openToAll]: "Open to all",
};

export const PLAN_LABELS: Record<PremiumPlanEnum, string> = {
  [PremiumPlanEnum.monthly]: "Monthly",
  [PremiumPlanEnum.yearly]: "Yearly",
};

export const PAYMENT_STATUS_LABELS: Record<PaymentStatusEnum, string> = {
  [PaymentStatusEnum.succeeded]: "Paid",
  [PaymentStatusEnum.pending]: "Pending",
  [PaymentStatusEnum.failed]: "Failed",
  [PaymentStatusEnum.cancelled]: "Cancelled",
};

export const NOTIFICATION_LABELS: Record<NotificationKindEnum, string> = {
  [NotificationKindEnum.newMatch]: "New match",
  [NotificationKindEnum.newMessage]: "New message",
  [NotificationKindEnum.likedYou]: "Someone liked you",
  [NotificationKindEnum.superLike]: "Super like",
  [NotificationKindEnum.subscriptionExpiry]: "Subscription",
};

export const REPORT_REASON_LABELS: Record<ReportReasonEnum, string> = {
  [ReportReasonEnum.spam]: "Spam",
  [ReportReasonEnum.fakeProfile]: "Fake profile",
  [ReportReasonEnum.harassment]: "Harassment",
  [ReportReasonEnum.inappropriateContent]: "Inappropriate content",
  [ReportReasonEnum.underage]: "Underage user",
  [ReportReasonEnum.other]: "Something else",
};

export const REPORT_STATUS_LABELS: Record<ReportStatusEnum, string> = {
  [ReportStatusEnum.open]: "Open",
  [ReportStatusEnum.resolved]: "Resolved",
  [ReportStatusEnum.dismissed]: "Dismissed",
};

export const INTEREST_OPTIONS = [
  "Café Hopping",
  "Traveler",
  "Dog Lover",
  "Cat Lover",
  "Creative",
  "Foodie",
  "Fitness",
  "Music",
  "Movies",
  "Reading",
  "Photography",
  "Art",
  "Dancing",
  "Hiking",
  "Gaming",
  "Yoga",
  "Cooking",
  "Startups",
] as const;

export const CITY_OPTIONS = [
  "Mumbai",
  "Delhi",
  "Bengaluru",
  "Hyderabad",
  "Chennai",
  "Kolkata",
  "Pune",
  "Ahmedabad",
  "Jaipur",
  "Lucknow",
  "Chandigarh",
  "Kochi",
] as const;
