import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { initials } from "@/lib/format";
import { cn } from "@/lib/utils";
import type { Photo } from "@/types";

export function photoUrl(photo: Photo | undefined): string | undefined {
  if (!photo) return undefined;
  try {
    return photo.blob.getDirectURL();
  } catch {
    return undefined;
  }
}

export function primaryPhotoUrl(
  photos: Photo[],
  primaryIndex: bigint,
): string | undefined {
  if (photos.length === 0) return undefined;
  const index = Number(primaryIndex);
  const safeIndex = index >= 0 && index < photos.length ? index : 0;
  return photoUrl(photos[safeIndex]) ?? photoUrl(photos[0]);
}

type ProfileAvatarProps = {
  name: string;
  src?: string;
  size?: "sm" | "md" | "lg" | "xl";
  ring?: boolean;
  className?: string;
};

const SIZE_CLASSES: Record<NonNullable<ProfileAvatarProps["size"]>, string> = {
  sm: "size-9 text-xs",
  md: "size-12 text-sm",
  lg: "size-16 text-base",
  xl: "size-24 text-xl",
};

export function ProfileAvatar({
  name,
  src,
  size = "md",
  ring = false,
  className,
}: ProfileAvatarProps) {
  const avatar = (
    <Avatar className={cn(SIZE_CLASSES[size], "bg-secondary", className)}>
      {src && <AvatarImage src={src} alt={name} className="object-cover" />}
      <AvatarFallback className="bg-secondary font-display font-semibold text-primary">
        {initials(name)}
      </AvatarFallback>
    </Avatar>
  );

  if (!ring) return avatar;

  return (
    <span className="inline-flex rounded-full bg-gradient-ring p-[2.5px] shadow-elevated">
      {avatar}
    </span>
  );
}
