import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";

export function PageHeader({
  title,
  subtitle,
  action,
  className,
}: {
  title: string;
  subtitle?: string;
  action?: React.ReactNode;
  className?: string;
}) {
  return (
    <header
      className={cn(
        "flex flex-wrap items-end justify-between gap-3 pb-1",
        className,
      )}
    >
      <div className="min-w-0">
        <h1 className="font-display text-3xl font-semibold text-foreground sm:text-4xl">
          {title}
        </h1>
        {subtitle && (
          <p className="mt-1 text-sm text-muted-foreground">{subtitle}</p>
        )}
      </div>
      {action}
    </header>
  );
}

export function EmptyState({
  icon,
  title,
  description,
  action,
  ocid,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  action?: React.ReactNode;
  ocid?: string;
}) {
  return (
    <div
      data-ocid={ocid ?? "empty_state"}
      className="flex flex-col items-center justify-center gap-3 rounded-lg border border-dashed border-border bg-card/60 px-6 py-14 text-center"
    >
      <span className="flex size-14 items-center justify-center rounded-full bg-secondary text-primary">
        {icon}
      </span>
      <h2 className="font-display text-xl font-semibold text-foreground">
        {title}
      </h2>
      <p className="max-w-sm text-sm text-muted-foreground">{description}</p>
      {action}
    </div>
  );
}

export function ErrorState({
  message,
  onRetry,
}: {
  message: string;
  onRetry?: () => void;
}) {
  return (
    <div
      data-ocid="error_state"
      className="flex flex-col items-center gap-3 rounded-lg border border-destructive/30 bg-card px-6 py-10 text-center"
    >
      <p className="text-sm text-destructive">{message}</p>
      {onRetry && (
        <button
          type="button"
          data-ocid="retry_button"
          onClick={onRetry}
          className="rounded-full border border-border px-4 py-2 text-sm font-medium text-foreground transition-smooth hover:bg-secondary"
        >
          Try again
        </button>
      )}
    </div>
  );
}

export function CardSkeleton({ count = 3 }: { count?: number }) {
  const ids = Array.from({ length: count }, (_, i) => `skeleton-${i}`);
  return (
    <div data-ocid="loading_state" className="grid gap-4 sm:grid-cols-2">
      {ids.map((id) => (
        <div
          key={id}
          className="flex flex-col gap-3 rounded-lg border border-border bg-card p-4"
        >
          <Skeleton className="h-40 w-full rounded-md" />
          <Skeleton className="h-5 w-2/3" />
          <Skeleton className="h-4 w-1/2" />
        </div>
      ))}
    </div>
  );
}

export function ListSkeleton({ count = 4 }: { count?: number }) {
  const ids = Array.from({ length: count }, (_, i) => `row-skeleton-${i}`);
  return (
    <div data-ocid="loading_state" className="flex flex-col gap-3">
      {ids.map((id) => (
        <div
          key={id}
          className="flex items-center gap-3 rounded-lg border border-border bg-card p-3"
        >
          <Skeleton className="size-12 rounded-full" />
          <div className="flex-1 space-y-2">
            <Skeleton className="h-4 w-1/3" />
            <Skeleton className="h-3 w-2/3" />
          </div>
        </div>
      ))}
    </div>
  );
}
