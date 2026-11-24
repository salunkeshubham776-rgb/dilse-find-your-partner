import type { ApiError, Timestamp } from "@/backend";

/** Motoko `Time.now()` values are nanosecond bigints. */
export function timestampToDate(timestamp: Timestamp): Date | null {
  const date = new Date(Number(timestamp / 1_000_000n));
  return Number.isNaN(date.getTime()) ? null : date;
}

export function formatRelativeTime(timestamp: Timestamp): string {
  const date = timestampToDate(timestamp);
  if (!date) return "";
  const diffMs = Date.now() - date.getTime();
  const minutes = Math.floor(diffMs / 60_000);
  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  return date.toLocaleDateString(undefined, { month: "short", day: "numeric" });
}

export function formatDate(timestamp: Timestamp): string {
  const date = timestampToDate(timestamp);
  if (!date) return "—";
  return date.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export function formatMoney(cents: bigint, currency = "INR"): string {
  const amount = Number(cents) / 100;
  try {
    return new Intl.NumberFormat(undefined, {
      style: "currency",
      currency,
      maximumFractionDigits: amount % 1 === 0 ? 0 : 2,
    }).format(amount);
  } catch {
    return `${currency} ${amount.toFixed(2)}`;
  }
}

export function apiErrorMessage(error: ApiError): string {
  switch (error.__kind__) {
    case "unauthorized":
      return "Please sign in again to continue.";
    case "notFound":
      return "We couldn't find that. It may have been removed.";
    case "invalidInput":
      return error.invalidInput || "Please check the details and try again.";
    case "underage":
      return "You must be 18 or older to use DilSe.";
    case "banned":
      return "This account has been suspended.";
    case "likeLimitReached":
      return "You've used today's likes. Upgrade to Premium for unlimited likes.";
    case "notPremium":
      return "This feature is part of DilSe Premium.";
    case "alreadyExists":
      return "That already exists.";
    case "paymentFailed":
      return error.paymentFailed || "The payment could not be completed.";
    default:
      return "Something went wrong. Please try again.";
  }
}

export function errorMessage(error: unknown): string {
  if (error instanceof Error && error.message) return error.message;
  return "Something went wrong. Please try again.";
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
}

export function ageFromDateOfBirth(dateOfBirth: Timestamp): number {
  const dob = timestampToDate(dateOfBirth);
  if (!dob) return 0;
  const now = new Date();
  let age = now.getFullYear() - dob.getFullYear();
  const monthDiff = now.getMonth() - dob.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < dob.getDate())) {
    age -= 1;
  }
  return age;
}
