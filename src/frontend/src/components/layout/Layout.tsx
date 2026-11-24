import { SignInButton } from "@/components/InternetIdentity";
import { ProfileAvatar, primaryPhotoUrl } from "@/components/ProfileAvatar";
import { BottomNav, SidebarNav } from "@/components/layout/NavItems";
import {
  useCallerProfile,
  useIsAdmin,
  usePremiumStatus,
} from "@/hooks/useQueries";
import { cn } from "@/lib/utils";
import { useInternetIdentity } from "@caffeineai/core-infrastructure";
import { Link } from "@tanstack/react-router";
import { Crown, Heart, Sparkles } from "lucide-react";
import type { ReactNode } from "react";

function BrandMark() {
  return (
    <Link
      to="/discover"
      data-ocid="nav.brand.link"
      className="group inline-flex items-baseline gap-1 font-display text-2xl font-semibold tracking-tight text-foreground"
    >
      DilSe
      <span className="relative -top-1 inline-flex size-4 items-center justify-center rounded-full bg-gradient-primary text-primary-foreground shadow-subtle transition-transform group-hover:scale-110">
        <Heart className="size-2.5 fill-current" aria-hidden="true" />
      </span>
    </Link>
  );
}

function PremiumPill() {
  const { data: premium } = usePremiumStatus();
  if (premium?.premium) {
    return (
      <Link
        to="/premium"
        data-ocid="nav.premium.link"
        className="inline-flex items-center gap-1.5 rounded-full bg-gradient-premium px-3 py-1.5 text-xs font-semibold text-primary-foreground shadow-subtle transition-smooth hover:opacity-90"
      >
        <Crown className="size-3.5" aria-hidden="true" />
        Premium
      </Link>
    );
  }
  return (
    <Link
      to="/premium"
      data-ocid="nav.premium.link"
      className="inline-flex items-center gap-1.5 rounded-full border border-accent/30 bg-accent/10 px-3 py-1.5 text-xs font-semibold text-accent transition-smooth hover:bg-accent/20"
    >
      <Sparkles className="size-3.5" aria-hidden="true" />
      DilSe Premium
    </Link>
  );
}

function AccountChip() {
  const { data: profile } = useCallerProfile();
  const { isAuthenticated } = useInternetIdentity();
  if (!isAuthenticated) return null;
  const name = profile?.displayName ?? "Your profile";
  return (
    <Link
      to="/profile"
      data-ocid="nav.account.link"
      className="flex items-center gap-2 rounded-full border border-border bg-card py-1 pl-1 pr-3 transition-smooth hover:bg-secondary"
    >
      <ProfileAvatar
        name={name}
        src={
          profile
            ? primaryPhotoUrl(profile.photos, profile.primaryPhotoIndex)
            : undefined
        }
        size="sm"
      />
      <span className="hidden max-w-24 truncate text-sm font-medium text-foreground sm:block">
        {name}
      </span>
    </Link>
  );
}

export function Layout({ children }: { children: ReactNode }) {
  const { data: isAdmin } = useIsAdmin();
  const admin = isAdmin === true;
  const year = new Date().getFullYear();
  const hostname =
    typeof window !== "undefined" ? window.location.hostname : "";

  return (
    <div className="min-h-dvh bg-background">
      <header className="sticky top-0 z-30 border-b border-border bg-card/90 backdrop-blur-md">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between gap-3 px-4 sm:px-6">
          <div className="flex items-center gap-6">
            <BrandMark />
            <div className="hidden md:block">
              <PremiumPill />
            </div>
          </div>
          <div className="flex items-center gap-2 sm:gap-3">
            <div className="md:hidden">
              <PremiumPill />
            </div>
            <AccountChip />
            <SignInButton
              className={cn(
                "rounded-full border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground transition-smooth hover:bg-secondary hover:text-foreground",
              )}
            />
          </div>
        </div>
      </header>

      <div className="mx-auto flex max-w-6xl gap-8 px-4 pb-28 pt-6 sm:px-6 md:pb-12">
        <aside className="hidden w-56 shrink-0 md:block">
          <div className="sticky top-24 flex flex-col gap-6">
            <SidebarNav isAdmin={admin} />
            <div className="rounded-lg border border-border bg-gradient-premium p-4 text-primary-foreground shadow-elevated">
              <p className="font-display text-lg font-semibold leading-tight">
                Find your person
              </p>
              <p className="mt-1 text-xs text-primary-foreground/85">
                Premium unlocks unlimited likes and who liked you.
              </p>
              <Link
                to="/premium"
                data-ocid="nav.upgrade.link"
                className="mt-3 inline-flex rounded-full bg-card px-3 py-1.5 text-xs font-semibold text-primary transition-smooth hover:bg-card/90"
              >
                Upgrade
              </Link>
            </div>
          </div>
        </aside>

        <main className="min-w-0 flex-1">{children}</main>
      </div>

      <footer className="border-t border-border bg-secondary/40 px-4 py-6 pb-24 text-center text-xs text-muted-foreground md:pb-6">
        <div className="mx-auto flex max-w-6xl flex-col items-center gap-2">
          <div className="flex flex-wrap items-center justify-center gap-x-4 gap-y-1">
            <Link
              to="/legal/$doc"
              params={{ doc: "privacy" }}
              data-ocid="footer.privacy.link"
              className="hover:text-foreground"
            >
              Privacy Policy
            </Link>
            <Link
              to="/legal/$doc"
              params={{ doc: "terms" }}
              data-ocid="footer.terms.link"
              className="hover:text-foreground"
            >
              Terms of Service
            </Link>
          </div>
          <p>
            © {year}. Built with love using{" "}
            <a
              href={`https://caffeine.ai?utm_source=caffeine-footer&utm_medium=referral&utm_content=${encodeURIComponent(hostname)}`}
              target="_blank"
              rel="noreferrer"
              className="underline underline-offset-2 hover:text-foreground"
            >
              caffeine.ai
            </a>
          </p>
        </div>
      </footer>

      <BottomNav />
    </div>
  );
}
