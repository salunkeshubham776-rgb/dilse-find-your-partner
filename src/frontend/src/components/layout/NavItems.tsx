import { useUnreadNotificationCount } from "@/hooks/useQueries";
import { Link } from "@tanstack/react-router";
import {
  Bell,
  Compass,
  Heart,
  MessageCircle,
  ShieldCheck,
  User,
} from "lucide-react";

export type NavItem = {
  to: string;
  label: string;
  icon: typeof Compass;
  badge?: boolean;
};

export const PRIMARY_NAV: NavItem[] = [
  { to: "/discover", label: "Discover", icon: Compass },
  { to: "/matches", label: "Matches", icon: Heart },
  { to: "/chats", label: "Chats", icon: MessageCircle },
  { to: "/notifications", label: "Alerts", icon: Bell, badge: true },
  { to: "/profile", label: "Profile", icon: User },
];

export const ADMIN_NAV: NavItem = {
  to: "/admin",
  label: "Admin",
  icon: ShieldCheck,
};

function useUnreadBadge(): number {
  const { data } = useUnreadNotificationCount();
  return data ? Number(data) : 0;
}

export function BottomNav() {
  const unread = useUnreadBadge();
  return (
    <nav
      aria-label="Primary"
      data-ocid="nav.bottom"
      className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-card/95 pb-[env(safe-area-inset-bottom)] backdrop-blur-md md:hidden"
    >
      <ul className="mx-auto flex max-w-lg items-stretch justify-between px-2">
        {PRIMARY_NAV.map((item) => (
          <li key={item.to} className="flex-1">
            <Link
              to={item.to}
              data-ocid={`nav.${item.label.toLowerCase()}.link`}
              activeProps={{ className: "text-primary" }}
              inactiveProps={{ className: "text-muted-foreground" }}
              className="relative flex min-h-[56px] flex-col items-center justify-center gap-1 rounded-md px-1 py-2 text-[11px] font-medium transition-smooth hover:text-primary"
            >
              <span className="relative">
                <item.icon className="size-5" aria-hidden="true" />
                {item.badge && unread > 0 && (
                  <span
                    data-ocid="nav.notifications.badge"
                    className="absolute -right-2 -top-1.5 flex min-w-4 items-center justify-center rounded-full bg-primary px-1 text-[10px] font-semibold leading-4 text-primary-foreground"
                  >
                    {unread > 9 ? "9+" : unread}
                  </span>
                )}
              </span>
              {item.label}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}

export function SidebarNav({ isAdmin }: { isAdmin: boolean }) {
  const unread = useUnreadBadge();
  const items = isAdmin ? [...PRIMARY_NAV, ADMIN_NAV] : PRIMARY_NAV;
  return (
    <nav
      aria-label="Primary"
      data-ocid="nav.sidebar"
      className="flex flex-col gap-1"
    >
      {items.map((item) => (
        <Link
          key={item.to}
          to={item.to}
          data-ocid={`nav.${item.label.toLowerCase()}.link`}
          activeProps={{
            className: "bg-secondary text-primary font-semibold",
          }}
          inactiveProps={{
            className:
              "text-muted-foreground hover:bg-secondary/60 hover:text-foreground",
          }}
          className="flex items-center gap-3 rounded-md px-3 py-2.5 text-sm transition-smooth"
        >
          <item.icon className="size-5 shrink-0" aria-hidden="true" />
          <span className="flex-1">{item.label}</span>
          {item.badge && unread > 0 && (
            <span
              data-ocid="nav.notifications.badge"
              className="flex min-w-5 items-center justify-center rounded-full bg-primary px-1.5 text-[11px] font-semibold leading-5 text-primary-foreground"
            >
              {unread > 9 ? "9+" : unread}
            </span>
          )}
        </Link>
      ))}
    </nav>
  );
}
