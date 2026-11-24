import type { Principal } from "@icp-sdk/core/principal";
export interface Some<T> {
    __kind__: "Some";
    value: T;
}
export interface None {
    __kind__: "None";
}
export type Option<T> = Some<T> | None;
import type { ExternalBlob } from "@caffeineai/object-storage";
export type { ExternalBlob } from "@caffeineai/object-storage";
export interface AdminOverview {
    activeUsers: bigint;
    revenue: RevenueSummary;
    totalUsers: bigint;
}
export interface AdminUserView {
    verified: boolean;
    displayName: string;
    premium: boolean;
    city: string;
    userId: UserId;
    createdAt: Timestamp;
    banned: boolean;
}
export interface Advertisement {
    id: Id;
    title: string;
    active: boolean;
    body: string;
    createdAt: Timestamp;
}
export interface AdvertisementInput {
    title: string;
    body: string;
}
export type ApiError = {
    __kind__: "notPremium";
    notPremium: null;
} | {
    __kind__: "alreadyExists";
    alreadyExists: null;
} | {
    __kind__: "banned";
    banned: null;
} | {
    __kind__: "invalidInput";
    invalidInput: string;
} | {
    __kind__: "underage";
    underage: null;
} | {
    __kind__: "likeLimitReached";
    likeLimitReached: null;
} | {
    __kind__: "notFound";
    notFound: null;
} | {
    __kind__: "unauthorized";
    unauthorized: null;
} | {
    __kind__: "paymentFailed";
    paymentFailed: string;
};
export interface Boost {
    startedAt: Timestamp;
    expiresAt: Timestamp;
    userId: UserId;
}
export interface Candidate {
    score: bigint;
    sharedInterests: Array<string>;
    profile: ProfileView;
}
export interface Cell {
    value: Value;
    name: string;
}
export interface ConversationView {
    lastMessageAt?: Timestamp;
    lastMessagePreview?: string;
    other: ProfileView;
    matchId: Id;
    unreadCount: bigint;
}
export interface DiscoverFilter {
    relationshipPreference?: RelationshipPreference;
    interests?: Array<string>;
    city?: string;
    verifiedOnly?: boolean;
    ageMax?: bigint;
    ageMin?: bigint;
}
export type Error_ = {
    __kind__: "FrontendOriginsNotConfigured";
    FrontendOriginsNotConfigured: null;
} | {
    __kind__: "MixedSsoSources";
    MixedSsoSources: {
        otherKeys: Array<string>;
        ssoKeys: Array<string>;
    };
} | {
    __kind__: "Stale";
    Stale: {
        ageNs: bigint;
    };
} | {
    __kind__: "MalformedCandid";
    MalformedCandid: null;
} | {
    __kind__: "AmbiguousAttribute";
    AmbiguousAttribute: {
        field: string;
        sources: Array<string>;
    };
} | {
    __kind__: "NoAttributes";
    NoAttributes: null;
} | {
    __kind__: "UnknownNonce";
    UnknownNonce: null;
} | {
    __kind__: "UntrustedSsoSource";
    UntrustedSsoSource: {
        domain: string;
    };
} | {
    __kind__: "MissingField";
    MissingField: string;
} | {
    __kind__: "FrontendOriginMismatch";
    FrontendOriginMismatch: {
        got: string;
        expected: Array<string>;
    };
};
export interface HttpHeader {
    value: string;
    name: string;
}
export interface HttpRequestResult {
    status: bigint;
    body: Uint8Array;
    headers: Array<HttpHeader>;
}
export type Id = bigint;
export type LikeResult = {
    __kind__: "liked";
    liked: null;
} | {
    __kind__: "matched";
    matched: {
        matchId: Id;
    };
} | {
    __kind__: "limitReached";
    limitReached: null;
};
export interface MatchView {
    id: Id;
    lastMessageAt?: Timestamp;
    lastMessagePreview?: string;
    other: ProfileView;
    createdAt: Timestamp;
    unreadCount: bigint;
}
export interface Message {
    id: Id;
    content: MessageContent;
    createdAt: Timestamp;
    sender: UserId;
    matchId: Id;
}
export type MessageContent = {
    __kind__: "text";
    text: string;
} | {
    __kind__: "image";
    image: Photo;
};
export interface NotificationView {
    id: Id;
    title: string;
    body: string;
    kind: NotificationKind;
    createdAt: Timestamp;
    read: boolean;
}
export interface OnboardingInput {
    bio: string;
    relationshipPreference: RelationshipPreference;
    displayName: string;
    interests: Array<string>;
    dateOfBirth: bigint;
    city: string;
    preferredAgeMax: bigint;
    preferredAgeMin: bigint;
    gender: Gender;
    preferredGender?: Gender;
}
export interface PaymentView {
    id: Id;
    status: PaymentStatus;
    superLikeCount: bigint;
    createdAt: Timestamp;
    plan?: PremiumPlan;
    amountCents: bigint;
    currency: string;
}
export interface Photo {
    blob: ExternalBlob;
    mimeType: string;
    filename: string;
}
export interface PremiumStatus {
    premium: boolean;
    subscription?: SubscriptionView;
    likesUsedToday: bigint;
    boostAvailable: boolean;
    dailyLikeLimit: bigint;
    superLikes: bigint;
}
export interface ProfileUpdate {
    bio: string;
    relationshipPreference: RelationshipPreference;
    displayName: string;
    interests: Array<string>;
    city: string;
    preferredAgeMax: bigint;
    preferredAgeMin: bigint;
    gender: Gender;
    preferredGender?: Gender;
}
export interface ProfileView {
    age: bigint;
    bio: string;
    verified: boolean;
    relationshipPreference: RelationshipPreference;
    displayName: string;
    premium: boolean;
    interests: Array<string>;
    city: string;
    userId: UserId;
    gender: Gender;
    primaryPhotoIndex: bigint;
    photos: Array<Photo>;
}
export interface Report {
    id: Id;
    status: ReportStatus;
    createdAt: Timestamp;
    details: string;
    reported: UserId;
    reporter: UserId;
    reason: ReportReason;
}
export interface Result {
    hasMore: boolean;
    rows: Array<Array<Cell>>;
}
export type Result__1 = {
    __kind__: "ok";
    ok: null;
} | {
    __kind__: "err";
    err: Error_;
};
export interface RevenueSummary {
    monthCents: bigint;
    yearCents: bigint;
    todayCents: bigint;
}
export interface ShoppingItem {
    productName: string;
    currency: string;
    quantity: bigint;
    priceInCents: bigint;
    productDescription: string;
}
export interface StripeConfiguration {
    allowedCountries: Array<string>;
    secretKey: string;
}
export type StripeSessionStatus = {
    __kind__: "completed";
    completed: {
        userPrincipal?: string;
        response: string;
    };
} | {
    __kind__: "failed";
    failed: {
        error: string;
    };
};
export interface SubscriptionView {
    startedAt: Timestamp;
    active: boolean;
    expiresAt: Timestamp;
    plan: PremiumPlan;
}
export type Timestamp = bigint;
export interface TransformationInput {
    context: Uint8Array;
    response: HttpRequestResult;
}
export interface TransformationOutput {
    status: bigint;
    body: Uint8Array;
    headers: Array<HttpHeader>;
}
export type UserId = Principal;
export type Value = {
    __kind__: "int";
    int: bigint;
} | {
    __kind__: "nat";
    nat: bigint;
} | {
    __kind__: "float";
    float: number;
} | {
    __kind__: "bool";
    bool: boolean;
} | {
    __kind__: "null";
    null: null;
} | {
    __kind__: "text";
    text: string;
};
export enum Gender {
    other = "other",
    female = "female",
    male = "male",
    nonBinary = "nonBinary"
}
export enum LikeKind {
    like = "like",
    superLike = "superLike"
}
export enum NotificationKind {
    newMatch = "newMatch",
    subscriptionExpiry = "subscriptionExpiry",
    superLike = "superLike",
    likedYou = "likedYou",
    newMessage = "newMessage"
}
export enum PaymentStatus {
    cancelled = "cancelled",
    pending = "pending",
    failed = "failed",
    succeeded = "succeeded"
}
export enum PremiumPlan {
    monthly = "monthly",
    yearly = "yearly"
}
export enum RelationshipPreference {
    friendship = "friendship",
    openToAll = "openToAll",
    casualDating = "casualDating",
    longTerm = "longTerm"
}
export enum ReportReason {
    other = "other",
    spam = "spam",
    underage = "underage",
    fakeProfile = "fakeProfile",
    harassment = "harassment",
    inappropriateContent = "inappropriateContent"
}
export enum ReportStatus {
    resolved = "resolved",
    open = "open",
    dismissed = "dismissed"
}
export enum UserRole {
    admin = "admin",
    user = "user",
    guest = "guest"
}
export interface backendInterface {
    adminCreateAd(input: AdvertisementInput): Promise<Advertisement>;
    adminListAds(): Promise<Array<Advertisement>>;
    adminListPayments(): Promise<Array<PaymentView>>;
    adminListReports(): Promise<Array<Report>>;
    adminListSubscriptions(): Promise<Array<SubscriptionView>>;
    adminListUsers(search: string | null): Promise<Array<AdminUserView>>;
    adminOverview(): Promise<AdminOverview>;
    adminResolveReport(reportId: Id, status: ReportStatus): Promise<void>;
    adminSetAdActive(adId: Id, active: boolean): Promise<void>;
    adminSetBanned(userId: UserId, banned: boolean): Promise<void>;
    adminSetVerified(userId: UserId, verified: boolean): Promise<void>;
    assignCallerUserRole(user: Principal, role: UserRole): Promise<void>;
    completeOnboarding(input: OnboardingInput): Promise<{
        __kind__: "ok";
        ok: ProfileView;
    } | {
        __kind__: "err";
        err: ApiError;
    }>;
    confirmCheckout(sessionId: string): Promise<{
        __kind__: "ok";
        ok: SubscriptionView;
    } | {
        __kind__: "err";
        err: ApiError;
    }>;
    createCheckoutSession(items: Array<ShoppingItem>, successUrl: string, cancelUrl: string): Promise<string>;
    discoverCandidates(filter: DiscoverFilter): Promise<Array<Candidate>>;
    execute(qJson: string): Promise<Result>;
    getApiDoc(): Promise<string>;
    getCallerProfile(): Promise<ProfileView | null>;
    getCallerUserRole(): Promise<UserRole>;
    getMatch(matchId: Id): Promise<MatchView | null>;
    getMessages(matchId: Id): Promise<Array<Message>>;
    getPremiumStatus(): Promise<PremiumStatus>;
    getProfile(userId: UserId): Promise<ProfileView | null>;
    getStripeSessionStatus(sessionId: string): Promise<StripeSessionStatus>;
    isCallerAdmin(): Promise<boolean>;
    isStripeConfigured(): Promise<boolean>;
    likeUser(target: UserId, kind: LikeKind): Promise<LikeResult>;
    listActiveAds(): Promise<Array<Advertisement>>;
    listConversations(): Promise<Array<ConversationView>>;
    listMatches(): Promise<Array<MatchView>>;
    listNotifications(): Promise<Array<NotificationView>>;
    listPayments(): Promise<Array<PaymentView>>;
    markAllNotificationsRead(): Promise<void>;
    markConversationRead(matchId: Id): Promise<void>;
    markNotificationRead(notificationId: Id): Promise<void>;
    notifySubscriptionExpiry(expiresAt: Timestamp): Promise<void>;
    passUser(target: UserId): Promise<void>;
    schema(): Promise<string>;
    sendMessage(matchId: Id, content: MessageContent): Promise<{
        __kind__: "ok";
        ok: Message;
    } | {
        __kind__: "err";
        err: ApiError;
    }>;
    setProfilePhotos(photos: Array<Photo>, primaryIndex: bigint): Promise<{
        __kind__: "ok";
        ok: ProfileView;
    } | {
        __kind__: "err";
        err: ApiError;
    }>;
    setStripeConfiguration(config: StripeConfiguration): Promise<void>;
    startProfileBoost(): Promise<{
        __kind__: "ok";
        ok: Boost;
    } | {
        __kind__: "err";
        err: ApiError;
    }>;
    transform(input: TransformationInput): Promise<TransformationOutput>;
    unreadNotificationCount(): Promise<bigint>;
    updateProfile(input: ProfileUpdate): Promise<{
        __kind__: "ok";
        ok: ProfileView;
    } | {
        __kind__: "err";
        err: ApiError;
    }>;
    whoLikedMe(): Promise<Array<ProfileView>>;
}
