mixin () {
  public query func getApiDoc() : async Text {
    "# DilSe Backend API\n" #
    "\n" #
    "DilSe is a dating application for adults aged 18 and over. This canister stores user profiles, likes, matches, private messages, subscriptions, payments, reports, notifications and advertisements. All personal data stays private: other users only ever see a public profile projection (display name, age, gender, city, bio, interests, photos, verification and premium badges). Phone numbers and exact locations are never stored or exposed.\n" #
    "\n" #
    "## Authentication and identity\n" #
    "\n" #
    "Every method that reads or writes user data requires a signed-in caller (a non-anonymous Internet Identity principal). Anonymous callers are rejected. The app's frontend pins an Internet Identity derivation origin, published at `/.well-known/ii-derivation-origin` when available; an agent already holding the user's Internet Identity authorization derives the correct per-app principal against that origin (for example `icp identity link web <name> --app <host>`). Such a delegation acts with the user's full authority in this app until it expires.\n" #
    "\n" #
    "### Registration prerequisite\n" #
    "\n" #
    "Access is role-gated. A direct API caller must register once by calling `_initialize_access_control` as a signed-in caller before any role-guarded call, including guarded queries. The first caller to initialize becomes `admin`; every later caller becomes `user`. A caller that never registered through the app's own frontend is unregistered even if it belongs to the app's owner, and a principal derived against a different origin is a different principal than the one the frontend registered. An unregistered caller on a role-guarded endpoint receives the trap `User is not registered`; an anonymous caller receives `Unauthorized: Only users can perform this action` on user-guarded endpoints or `Sign in to continue` on signed-in-only endpoints.\n" #
    "\n" #
    "## Units and encodings\n" #
    "\n" #
    "- Timestamps are signed `Int` nanoseconds since the Unix epoch (from `Time.now()`).\n" #
    "- `dateOfBirth` is a UTC epoch-day count (whole days since 1970-01-01); age is derived from it.\n" #
    "- Identifiers: `UserId` is a `Principal`; record ids are `Nat`.\n" #
    "- Money amounts are integer cents (`amountCents`) with a lowercase currency code (for example `usd`).\n" #
    "- Photos are `Photo` records holding an object-storage `ExternalBlob` plus filename and MIME type.\n" #
    "- Optional values are Candid `opt`; variants use their tag names.\n" #
    "\n" #
    "## Profiles\n" #
    "\n" #
    "- `completeOnboarding(input)` creates the caller's profile. Rejects under-18 callers (`#underage`), duplicate profiles (`#alreadyExists`) and empty name/city (`#invalidInput`).\n" #
    "- `updateProfile(input)` and `setProfilePhotos(photos, primaryIndex)` update the caller's own profile (max 6 photos).\n" #
    "- `getCallerProfile()` and `getProfile(userId)` return the public `ProfileView` projection.\n" #
    "\n" #
    "## Discover and matching\n" #
    "\n" #
    "- `discoverCandidates(filter)` returns ranked candidates excluding the caller, already-liked, already-passed and blocked users. Filter by city, age range, interests, relationship preference and verified-only.\n" #
    "- `likeUser(target, kind)` records a like or super-like. A mutual like creates a match and returns `#matched({ matchId })`. Returns `#limitReached` when a non-premium caller exceeds the daily like limit or a super-like has no balance. Re-liking an already-liked user is idempotent and returns `#liked`.\n" #
    "- `passUser(target)` records a pass.\n" #
    "- `whoLikedMe()` returns profiles that liked the caller.\n" #
    "- `listMatches()` and `getMatch(matchId)` return the caller's matches.\n" #
    "\n" #
    "## Chat\n" #
    "\n" #
    "- `listConversations()` lists the caller's conversations with unread counts.\n" #
    "- `getMessages(matchId)` returns message history for a match the caller belongs to.\n" #
    "- `sendMessage(matchId, content)` sends a text or image message; empty text is rejected. Blocked pairs cannot message.\n" #
    "- `markConversationRead(matchId)` advances the caller's read state.\n" #
    "- `blockUser(target)` / `unblockUser(target)` manage blocks; blocking removes any existing match.\n" #
    "- `reportUser(input)` files a complaint.\n" #
    "\n" #
    "## Premium and payments\n" #
    "\n" #
    "- `getPremiumStatus()` returns premium state, super-like balance, boost availability and daily like usage.\n" #
    "- `startProfileBoost()` starts a 30-minute boost (once per day).\n" #
    "- `listPayments()` lists the caller's payments.\n" #
    "- `confirmCheckout(sessionId)` verifies a Stripe checkout session and activates premium or credits super-likes only after the provider confirms payment. It is idempotent for an already-succeeded payment.\n" #
    "\n" #
    "## Notifications\n" #
    "\n" #
    "- `listNotifications()`, `unreadNotificationCount()`, `markNotificationRead(id)` and `markAllNotificationsRead()` operate on the caller's own notifications.\n" #
    "\n" #
    "## Advertisements\n" #
    "\n" #
    "- `listActiveAds()` is public and returns active ad placements.\n" #
    "\n" #
    "## Admin\n" #
    "\n" #
    "Admin-only methods (guarded by the `admin` role; non-admins receive `Unauthorized: Only admins can perform this action`): `adminOverview`, `adminListUsers`, `adminSetVerified`, `adminSetBanned`, `adminListReports`, `adminResolveReport`, `adminListPayments`, `adminListSubscriptions`, `adminListAds`, `adminCreateAd`, `adminSetAdActive`.\n" #
    "\n" #
    "## Lifecycle, polling and retry safety\n" #
    "\n" #
    "- Queries (`discoverCandidates`, `whoLikedMe`, `listMatches`, `getMessages`, `listConversations`, `getPremiumStatus`, `listNotifications`, `listActiveAds`, `getProfile`) are read-only and safe to poll.\n" #
    "- Mutations are update calls. `likeUser` and `confirmCheckout` are idempotent for repeated calls with the same target/session. `passUser`, `markConversationRead` and `markNotificationRead` are safe to repeat. `sendMessage` is not idempotent: a retried call creates a second message.\n" #
    "- Premium activates only after payment verification; a pending payment stays pending until `confirmCheckout` observes a paid session.\n" #
    "\n" #
    "## Errors\n" #
    "\n" #
    "Errors are returned as `ApiError` variants (`#unauthorized`, `#notFound`, `#invalidInput(text)`, `#underage`, `#banned`, `#likeLimitReached`, `#notPremium`, `#alreadyExists`, `#paymentFailed(text)`) or as traps for authorization and invariant failures. Traps roll back the message's state changes."
  };
};
