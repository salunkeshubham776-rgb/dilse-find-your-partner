# Design Brief

## Direction

Blush Editorial — a warm, premium dating app where rose-magenta romance meets calm editorial clarity.

## Tone

Refined romantic warmth: trustworthy and grown-up, never childish or garish; soft surfaces carry confident type.

## Differentiation

Signature gradient rings frame every profile photo, making each card feel like a framed portrait in a luxury magazine.

## Color Palette

| Token      | OKLCH          | Role                          |
| ---------- | -------------- | ----------------------------- |
| background | 0.985 0.008 30 | warm blush-white canvas       |
| foreground | 0.22 0.045 340 | deep plum ink text            |
| card       | 1 0 0          | crisp white raised surfaces   |
| primary    | 0.56 0.2 355   | rose-magenta CTA, like action |
| accent     | 0.58 0.19 305  | violet premium emphasis       |
| muted      | 0.955 0.016 20 | soft blush section fills      |

## Typography

- Display: Fraunces — wordmark, page headings, profile names, match celebration
- Body: General Sans — labels, bios, buttons, navigation, chat
- Scale: hero `text-4xl md:text-6xl font-semibold tracking-tight`, h2 `text-2xl md:text-3xl`, label `text-xs font-semibold tracking-widest uppercase`, body `text-base`

## Elevation & Depth

White cards float on blush canvas via layered plum-tinted shadows (`shadow-card`, `shadow-elevated`); depth from soft diffuse light, never hard borders.

## Structural Zones

| Zone    | Background           | Border    | Notes                                      |
| ------- | -------------------- | --------- | ------------------------------------------ |
| Header  | `bg-card/95` blur    | `border-b`| Wordmark left, premium pill right, shadow-subtle |
| Content | `bg-background`      | —         | Alternate `bg-muted/40` sections for rhythm |
| Nav     | floating `bg-card/90`| `border`  | Glass bar, active tab primary, safe-area pad |
| Footer  | `bg-muted/40`        | `border-t`| Legal links, muted text                    |

## Spacing & Rhythm

Mobile-first; sections gap `py-10 md:py-16`, card interiors `p-5 md:p-6`, chip gaps `gap-2`; generous air around focal cards.

## Component Patterns

- Buttons: pill (`rounded-full`), primary gradient fill, outline secondary, hover lift + shadow
- Cards: `rounded-[1.5rem]` white, `shadow-card`, gradient-ring photo, `animate-card-enter`
- Badges: pill chips on `bg-secondary`, verified/premium use accent violet with icon

## Motion

- Entrance: `animate-fade-up` / `animate-card-enter` 0.45–0.5s ease-out, staggered
- Hover: `transition-smooth` 0.3s lift and shadow deepen on cards/buttons
- Decorative: `animate-heart-pop` on like, `animate-float` on orbs, `animate-shimmer` on premium

## Constraints

- Semantic tokens only; no raw hex or arbitrary color classes
- Mobile-first; thumb-friendly actions and floating bottom nav
- Warm and trustworthy tone; no garish gradients or bouncy animation

## Signature Detail

The tri-color gradient portrait ring (rose → violet → coral) that unifies profile, match, and premium surfaces.
