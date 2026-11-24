import { Layout } from "@/components/layout/Layout";
import { useCallerProfile } from "@/hooks/useQueries";
import { LegalPage } from "@/pages/LegalPage";
import { OnboardingPage } from "@/pages/OnboardingPage";
import { WelcomePage } from "@/pages/WelcomePage";
import { useInternetIdentity } from "@caffeineai/core-infrastructure";
import {
  Outlet,
  RouterProvider,
  createRootRoute,
  createRoute,
  createRouter,
} from "@tanstack/react-router";
import { Heart } from "lucide-react";
import type { ReactNode } from "react";

function RoutePlaceholder({ title }: { title: string }) {
  return (
    <div className="flex flex-col gap-2">
      <h1 className="font-display text-3xl font-semibold text-foreground">
        {title}
      </h1>
      <p className="text-sm text-muted-foreground">
        This section is being prepared.
      </p>
    </div>
  );
}

function LoadingScreen({ label }: { label: string }) {
  return (
    <div
      data-ocid="app.loading_state"
      className="flex min-h-dvh flex-col items-center justify-center gap-3 bg-background text-muted-foreground"
    >
      <span className="inline-flex size-12 animate-float items-center justify-center rounded-full bg-gradient-primary text-primary-foreground">
        <Heart className="size-5 fill-current" aria-hidden="true" />
      </span>
      <p className="text-sm">{label}</p>
    </div>
  );
}

/** Signed-out visitors see the welcome screen; signed-in users without a profile onboard first. */
function Gate({ children }: { children: ReactNode }) {
  const { isAuthenticated, isInitializing, isLoggingIn } =
    useInternetIdentity();
  const { data: profile, isLoading, isFetched } = useCallerProfile();

  if (isInitializing || isLoggingIn)
    return <LoadingScreen label="Loading your session…" />;
  if (!isAuthenticated) return <WelcomePage />;
  if (isLoading || !isFetched)
    return <LoadingScreen label="Loading your profile…" />;
  if (profile === null) return <OnboardingPage />;
  return <>{children}</>;
}

function RootComponent() {
  return <Outlet />;
}

function AppShell() {
  return (
    <Layout>
      <Outlet />
    </Layout>
  );
}

const rootRoute = createRootRoute({ component: RootComponent });

const welcomeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/",
  component: WelcomePage,
});

const appRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "app",
  component: AppShell,
});

const discoverRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/discover",
  component: () => <RoutePlaceholder title="Discover" />,
});
const matchesRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/matches",
  component: () => <RoutePlaceholder title="Matches" />,
});
const chatsRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/chats",
  component: () => <RoutePlaceholder title="Chats" />,
});
const notificationsRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/notifications",
  component: () => <RoutePlaceholder title="Notifications" />,
});
const profileRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/profile",
  component: () => <RoutePlaceholder title="Profile" />,
});
const premiumRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/premium",
  component: () => <RoutePlaceholder title="DilSe Premium" />,
});
const adminRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/admin",
  component: () => <RoutePlaceholder title="Admin" />,
});

const chatRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/chats/$matchId",
  component: () => <RoutePlaceholder title="Conversation" />,
});

const legalRoute = createRoute({
  getParentRoute: () => appRoute,
  path: "/legal/$doc",
  component: LegalPage,
});

const routeTree = rootRoute.addChildren([
  welcomeRoute,
  appRoute.addChildren([
    discoverRoute,
    matchesRoute,
    chatsRoute,
    chatRoute,
    notificationsRoute,
    profileRoute,
    premiumRoute,
    adminRoute,
    legalRoute,
  ]),
]);

const router = createRouter({ routeTree, defaultPreload: "intent" });

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

export default function App() {
  return (
    <Gate>
      <RouterProvider router={router} />
    </Gate>
  );
}
