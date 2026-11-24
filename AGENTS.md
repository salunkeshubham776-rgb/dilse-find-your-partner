# Project Guidance

## User Preferences

- Premium pink, purple and white color theme
- Beautiful profile cards with smooth animations
- Mobile-first responsive design with simple navigation

## Accepted Requirements

- Sign-in with secure authentication and 18+ only registration
- Profile with photos, name, age, gender, city, bio, interests, relationship preferences and verification badge
- Discover with city and age search, like and dislike, and smart recommendations
- Mutual-like matching with match notifications and chat access
- Private messaging with image sharing, block and report
- Premium subscription with unlimited likes, who liked you, profile boost, advanced filters and premium badge
- Monthly and yearly subscription plans with secure payment verification and automatic premium activation
- Admin dashboard with user counts, profile management, verification, complaints, bans, subscriptions, revenue and advertisements
- Privacy protection: no public phone numbers or exact locations, plus privacy policy and terms
- Notifications for new match, new message, someone liked you and subscription expiry

## Verified Commands

- **typecheck**: `pnpm typecheck`
- **fix**: `pnpm fix`
- **build**: `pnpm build`

## Learnings

- Backend commands from src/backend/: mops check --fix, mops build; bindings from the repo root: pnpm bindgen; frontend from src/frontend/: pnpm typecheck, pnpm fix.
- Mixin helper names collide across Motoko includes; prefix per-domain helpers such as chatOtherOf and requireChatUser.
- AccessControl.isAdmin traps for unregistered callers; read accessControlState.userRoles directly and treat non-admin as unauthorized.
- OQL auto-derive needs a top-level _toRow per variant field; records with array fields such as Profile use toEntityManual with .payload.
- Photo.blob is an ExternalBlob rendered through blob.getDirectURL(); the frontend helpers photoUrl and primaryPhotoUrl wrap it.
- TanStack Router route paths are typed from the route tree; declare createRoute with a literal path and use useParams({ from: '/app/legal/$doc' }).
- Stripe.getSessionStatus needs OutCall.Transform passed through the mixin from main.mo; verify payment_status paid and client_reference_id before activating premium.
- The moderation mixin must be included in src/backend/main.mo, otherwise blockUser, unblockUser and reportUser never reach the generated bindings and the frontend hooks that call them fail to typecheck.
