import { cn } from "@/lib/utils";
import { BadgeCheck, Crown } from "lucide-react";

export function VerifiedBadge({ className }: { className?: string }) {
  return (
    <span
      className={cn("inline-flex items-center text-accent", className)}
      title="Verified profile"
    >
      <BadgeCheck className="size-5 fill-accent text-card" aria-hidden="true" />
      <span className="sr-only">Verified profile</span>
    </span>
  );
}

export function PremiumBadge({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 rounded-full bg-gradient-premium px-2 py-0.5 text-[11px] font-semibold text-primary-foreground",
        className,
      )}
    >
      <Crown className="size-3" aria-hidden="true" />
      Premium
    </span>
  );
}
