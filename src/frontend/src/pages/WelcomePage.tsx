import { SignInButton } from "@/components/InternetIdentity";
import { useInternetIdentity } from "@caffeineai/core-infrastructure";
import { Link } from "@tanstack/react-router";
import { Heart, ShieldCheck, Sparkles, Users } from "lucide-react";

const HIGHLIGHTS = [
  {
    icon: Heart,
    title: "Meaningful matches",
    body: "Mutual likes open a private chat — no cold messages, ever.",
  },
  {
    icon: ShieldCheck,
    title: "Verified & private",
    body: "18+ only, verified badges, and no phone numbers or exact locations shared.",
  },
  {
    icon: Users,
    title: "People near you",
    body: "Browse by city and age, with interests that actually line up.",
  },
];

export function WelcomePage() {
  const { isAuthenticated, isInitializing, isLoggingIn } =
    useInternetIdentity();

  return (
    <div className="min-h-dvh bg-background">
      <div className="mx-auto flex min-h-dvh max-w-6xl flex-col px-4 py-6 sm:px-6">
        <header className="flex items-center justify-between">
          <span className="inline-flex items-baseline gap-1 font-display text-2xl font-semibold tracking-tight text-foreground">
            DilSe
            <span className="relative -top-1 inline-flex size-4 items-center justify-center rounded-full bg-gradient-primary text-primary-foreground">
              <Heart className="size-2.5 fill-current" aria-hidden="true" />
            </span>
          </span>
          <Link
            to="/legal/$doc"
            params={{ doc: "privacy" }}
            data-ocid="welcome.privacy.link"
            className="text-sm text-muted-foreground transition-smooth hover:text-foreground"
          >
            Privacy
          </Link>
        </header>

        <main className="grid flex-1 items-center gap-10 py-10 md:grid-cols-2 md:gap-16">
          <section className="animate-fade-up">
            <span className="inline-flex items-center gap-1.5 rounded-full border border-accent/30 bg-accent/10 px-3 py-1 text-xs font-semibold text-accent">
              <Sparkles className="size-3.5" aria-hidden="true" />
              Where hearts meet, DilSe
            </span>
            <h1 className="mt-5 font-display text-4xl font-semibold leading-[1.05] text-foreground sm:text-5xl lg:text-6xl">
              Meet someone who
              <span className="text-gradient-primary"> feels like home.</span>
            </h1>
            <p className="mt-5 max-w-md text-base leading-relaxed text-muted-foreground">
              A warm, honest place to find real connections. Sign in with your
              passkey, Google, Microsoft or company SSO — we never store a
              password.
            </p>

            <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
              {isAuthenticated ? (
                <Link
                  to="/discover"
                  data-ocid="welcome.continue_button"
                  className="inline-flex min-h-12 items-center justify-center rounded-full bg-gradient-primary px-7 text-sm font-semibold text-primary-foreground shadow-elevated transition-smooth hover:opacity-95"
                >
                  Continue to Discover
                </Link>
              ) : (
                <SignInButton className="inline-flex min-h-12 items-center justify-center rounded-full bg-gradient-primary px-7 text-sm font-semibold text-primary-foreground shadow-elevated transition-smooth hover:opacity-95 disabled:opacity-60" />
              )}
              <Link
                to="/legal/$doc"
                params={{ doc: "terms" }}
                data-ocid="welcome.terms.link"
                className="inline-flex min-h-12 items-center justify-center rounded-full border border-border px-6 text-sm font-medium text-foreground transition-smooth hover:bg-secondary"
              >
                Terms of Service
              </Link>
            </div>
            {(isInitializing || isLoggingIn) && (
              <p
                className="mt-3 text-xs text-muted-foreground"
                data-ocid="welcome.loading_state"
              >
                Preparing secure sign-in…
              </p>
            )}
            <p className="mt-4 text-xs text-muted-foreground">
              You must be 18 or older to join. By continuing you agree to our{" "}
              <Link
                to="/legal/$doc"
                params={{ doc: "terms" }}
                className="underline underline-offset-2 hover:text-foreground"
              >
                Terms
              </Link>{" "}
              and{" "}
              <Link
                to="/legal/$doc"
                params={{ doc: "privacy" }}
                className="underline underline-offset-2 hover:text-foreground"
              >
                Privacy Policy
              </Link>
              .
            </p>
          </section>

          <section aria-label="Why DilSe" className="grid gap-3">
            {HIGHLIGHTS.map((item, index) => (
              <article
                key={item.title}
                className="animate-card-enter rounded-lg border border-border bg-card p-5 shadow-card"
                style={{ animationDelay: `${index * 90}ms` }}
              >
                <div className="flex items-start gap-4">
                  <span className="flex size-11 shrink-0 items-center justify-center rounded-full bg-gradient-ring text-primary-foreground">
                    <item.icon className="size-5" aria-hidden="true" />
                  </span>
                  <div>
                    <h2 className="font-display text-lg font-semibold text-foreground">
                      {item.title}
                    </h2>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {item.body}
                    </p>
                  </div>
                </div>
              </article>
            ))}
          </section>
        </main>

        <footer className="border-t border-border pt-4 text-center text-xs text-muted-foreground">
          © {new Date().getFullYear()}. Built with love using{" "}
          <a
            href={`https://caffeine.ai?utm_source=caffeine-footer&utm_medium=referral&utm_content=${encodeURIComponent(typeof window !== "undefined" ? window.location.hostname : "")}`}
            target="_blank"
            rel="noreferrer"
            className="underline underline-offset-2 hover:text-foreground"
          >
            caffeine.ai
          </a>
        </footer>
      </div>
    </div>
  );
}
