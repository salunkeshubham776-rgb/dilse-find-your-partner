import {
  Ban,
  CreditCard,
  FileText,
  Flag,
  Lock,
  MapPin,
  ShieldCheck,
  Trash2,
  UserCheck,
} from "lucide-react";
import type { ReactNode } from "react";

export type LegalDoc = "privacy" | "terms";

export type LegalSection = {
  id: string;
  title: string;
  icon: ReactNode;
  body: ReactNode;
};

export const EFFECTIVE_DATE = "24 November 2026";

function P({ children }: { children: ReactNode }) {
  return (
    <p className="text-sm leading-relaxed text-muted-foreground">{children}</p>
  );
}

function Bullets({ items }: { items: string[] }) {
  return (
    <ul className="flex flex-col gap-2">
      {items.map((item) => (
        <li
          key={item}
          className="flex gap-2.5 text-sm leading-relaxed text-muted-foreground"
        >
          <span
            aria-hidden="true"
            className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary"
          />
          <span className="min-w-0">{item}</span>
        </li>
      ))}
    </ul>
  );
}

const PRIVACY_SECTIONS: LegalSection[] = [
  {
    id: "what-we-store",
    title: "What we store about you",
    icon: <FileText className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          DilSe keeps only what it needs to help you meet people. Your profile
          is tied to your secure sign-in identity, never to a password we hold.
        </P>
        <Bullets
          items={[
            "Profile details you add: display name, date of birth, gender, city, bio, interests and relationship preferences.",
            "Photos you upload, plus a verification badge once your profile is reviewed.",
            "Activity needed to run the app: likes, matches, messages, reports and blocks.",
            "Subscription status and payment records. Card details are handled by our payment provider and never stored on DilSe.",
          ]}
        />
      </div>
    ),
  },
  {
    id: "city-only",
    title: "Only your city is shown to others",
    icon: <MapPin className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          Other members can see the city you choose — nothing more precise. We
          never display your exact location, home address, phone number or email
          address on your profile.
        </P>
        <P>
          Your date of birth is used to confirm you are 18 or older and to show
          your age. It is never shown as a full date to other members.
        </P>
      </div>
    ),
  },
  {
    id: "who-sees-what",
    title: "Who can see your information",
    icon: <Lock className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          Your profile is visible to other signed-in members so they can
          discover and match with you. Messages are private to you and the
          person you are chatting with.
        </P>
        <P>
          Our moderation team can review reported profiles, messages and
          complaints to keep the community safe. We do not sell your personal
          data to anyone.
        </P>
      </div>
    ),
  },
  {
    id: "block-report-delete",
    title: "Block, report or delete your profile",
    icon: <ShieldCheck className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>You stay in control of your account at every step:</P>
        <div className="flex flex-col gap-3">
          {[
            {
              icon: Ban,
              label: "Block",
              text: "anyone from their profile or your chat. Blocking hides you from each other and ends the conversation.",
            },
            {
              icon: Flag,
              label: "Report",
              text: "a profile or message. Our team reviews every report and can warn, suspend or remove the account.",
            },
            {
              icon: Trash2,
              label: "Delete",
              text: "your profile from your profile settings at any time. Your profile, photos and matches are removed and you disappear from discovery.",
            },
          ].map((action) => (
            <div key={action.label} className="flex gap-2.5">
              <action.icon
                className="mt-0.5 size-4 shrink-0 text-primary"
                aria-hidden="true"
              />
              <p className="text-sm leading-relaxed text-muted-foreground">
                <strong className="font-semibold text-foreground">
                  {action.label}
                </strong>{" "}
                {action.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    ),
  },
  {
    id: "retention",
    title: "How long we keep data",
    icon: <Lock className="size-4" aria-hidden="true" />,
    body: (
      <P>
        We keep your information while your profile is active. When you delete
        your profile, your personal details and photos are removed. We may keep
        limited records of reports, blocks and payments for as long as needed to
        meet legal and safety obligations.
      </P>
    ),
  },
];

const TERMS_SECTIONS: LegalSection[] = [
  {
    id: "eligibility",
    title: "You must be 18 or older",
    icon: <UserCheck className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          DilSe is strictly for adults. By creating a profile you confirm that
          you are at least 18 years old and that the details you share are
          accurate.
        </P>
        <P>
          If we learn that a member is under 18, the account is removed
          immediately. Misrepresenting your age is a serious breach of these
          terms.
        </P>
      </div>
    ),
  },
  {
    id: "acceptable-behaviour",
    title: "Acceptable behaviour",
    icon: <ShieldCheck className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          DilSe works because members treat each other with respect. When you
          use the app you agree not to:
        </P>
        <Bullets
          items={[
            "Harass, threaten, stalk or abuse another member.",
            "Post nudity, hate speech, or content that is illegal or harmful.",
            "Impersonate anyone, or create fake or misleading profiles.",
            "Share another person's private information without consent.",
            "Use the app for spam, scams, solicitation or commercial promotion.",
          ]}
        />
        <P>
          We may warn, suspend or permanently ban accounts that break these
          rules, and we may remove content that does.
        </P>
      </div>
    ),
  },
  {
    id: "premium",
    title: "Premium subscriptions",
    icon: <CreditCard className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          DilSe Premium is optional and unlocks extra features such as unlimited
          likes, seeing who liked you, profile boosts and advanced filters.
        </P>
        <Bullets
          items={[
            "Premium is offered as a monthly or yearly plan at the price shown at checkout.",
            "Your subscription activates automatically once your payment is verified.",
            "Premium features are personal to your account and cannot be transferred.",
          ]}
        />
      </div>
    ),
  },
  {
    id: "payments",
    title: "Payment terms",
    icon: <CreditCard className="size-4" aria-hidden="true" />,
    body: (
      <div className="flex flex-col gap-3">
        <P>
          Payments are processed securely by our payment provider. Prices are
          shown in Indian Rupees and include applicable taxes unless stated
          otherwise.
        </P>
        <Bullets
          items={[
            "A plan renews for the period you selected until you cancel it.",
            "You can cancel renewal at any time; access continues until the end of the paid period.",
            "Because Premium unlocks instantly, payments are generally non-refundable except where required by law.",
          ]}
        />
      </div>
    ),
  },
  {
    id: "changes",
    title: "Changes to these terms",
    icon: <FileText className="size-4" aria-hidden="true" />,
    body: (
      <P>
        We may update these terms as DilSe grows. When we make meaningful
        changes we will let you know in the app. Continuing to use DilSe after
        an update means you accept the revised terms.
      </P>
    ),
  },
];

export const LEGAL_DOCS: Record<
  LegalDoc,
  { title: string; subtitle: string; sections: LegalSection[] }
> = {
  privacy: {
    title: "Privacy Policy",
    subtitle:
      "How DilSe collects, uses and protects your information — in plain language.",
    sections: PRIVACY_SECTIONS,
  },
  terms: {
    title: "Terms of Service",
    subtitle:
      "The rules for using DilSe, including the 18+ requirement and Premium payments.",
    sections: TERMS_SECTIONS,
  },
};

export function isLegalDoc(value: string): value is LegalDoc {
  return value === "privacy" || value === "terms";
}
