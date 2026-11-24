import { createActor } from "@/backend";
import type {
  AdvertisementInput,
  DiscoverFilter,
  Id,
  LikeKind,
  MessageContent,
  OnboardingInput,
  Photo,
  ProfileUpdate,
  ReportStatus,
  UserId,
  UserRole,
} from "@/types";
import { useActor } from "@caffeineai/core-infrastructure";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

export const queryKeys = {
  callerProfile: ["callerProfile"] as const,
  premiumStatus: ["premiumStatus"] as const,
  candidates: (filter: DiscoverFilter) => ["candidates", filter] as const,
  whoLikedMe: ["whoLikedMe"] as const,
  matches: ["matches"] as const,
  match: (matchId: Id) => ["match", matchId.toString()] as const,
  conversations: ["conversations"] as const,
  messages: (matchId: Id) => ["messages", matchId.toString()] as const,
  notifications: ["notifications"] as const,
  unreadCount: ["unreadNotificationCount"] as const,
  payments: ["payments"] as const,
  activeAds: ["activeAds"] as const,
  isAdmin: ["isAdmin"] as const,
  adminOverview: ["adminOverview"] as const,
  adminUsers: (search: string) => ["adminUsers", search] as const,
  adminReports: ["adminReports"] as const,
  adminPayments: ["adminPayments"] as const,
  adminSubscriptions: ["adminSubscriptions"] as const,
  adminAds: ["adminAds"] as const,
};

/* ------------------------------- Profile ------------------------------- */

export function useCallerProfile() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.callerProfile,
    queryFn: async () => {
      if (!actor) return null;
      return actor.getCallerProfile();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useProfile(userId: UserId | undefined) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: ["profile", userId?.toText() ?? "none"],
    queryFn: async () => {
      if (!actor || !userId) return null;
      return actor.getProfile(userId);
    },
    enabled: !!actor && !isFetching && !!userId,
  });
}

export function useCompleteOnboarding() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: OnboardingInput) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.completeOnboarding(input);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.callerProfile });
    },
  });
}

export function useUpdateProfile() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: ProfileUpdate) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.updateProfile(input);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.callerProfile });
    },
  });
}

export function useSetProfilePhotos() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { photos: Photo[]; primaryIndex: bigint }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.setProfilePhotos(args.photos, args.primaryIndex);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.callerProfile });
    },
  });
}

/* ------------------------------- Discover ------------------------------ */

export function useDiscoverCandidates(filter: DiscoverFilter) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.candidates(filter),
    queryFn: async () => {
      if (!actor) return [];
      return actor.discoverCandidates(filter);
    },
    enabled: !!actor && !isFetching,
  });
}

export function useLikeUser() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { target: UserId; kind: LikeKind }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.likeUser(args.target, args.kind);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["candidates"] });
      void queryClient.invalidateQueries({ queryKey: queryKeys.matches });
      void queryClient.invalidateQueries({ queryKey: queryKeys.premiumStatus });
      void queryClient.invalidateQueries({ queryKey: queryKeys.unreadCount });
    },
  });
}

export function usePassUser() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (target: UserId) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.passUser(target);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["candidates"] });
    },
  });
}

export function useWhoLikedMe() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.whoLikedMe,
    queryFn: async () => {
      if (!actor) return [];
      return actor.whoLikedMe();
    },
    enabled: !!actor && !isFetching,
  });
}

/* ------------------------------- Matches ------------------------------- */

export function useMatches() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.matches,
    queryFn: async () => {
      if (!actor) return [];
      return actor.listMatches();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useMatch(matchId: Id | undefined) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.match(matchId ?? 0n),
    queryFn: async () => {
      if (!actor || matchId === undefined) return null;
      return actor.getMatch(matchId);
    },
    enabled: !!actor && !isFetching && matchId !== undefined,
  });
}

/* --------------------------------- Chat -------------------------------- */

export function useConversations() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.conversations,
    queryFn: async () => {
      if (!actor) return [];
      return actor.listConversations();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useMessages(matchId: Id | undefined) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.messages(matchId ?? 0n),
    queryFn: async () => {
      if (!actor || matchId === undefined) return [];
      return actor.getMessages(matchId);
    },
    enabled: !!actor && !isFetching && matchId !== undefined,
    refetchInterval: 8000,
  });
}

export function useSendMessage() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { matchId: Id; content: MessageContent }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.sendMessage(args.matchId, args.content);
    },
    onSuccess: (_result, args) => {
      void queryClient.invalidateQueries({
        queryKey: queryKeys.messages(args.matchId),
      });
      void queryClient.invalidateQueries({ queryKey: queryKeys.conversations });
      void queryClient.invalidateQueries({ queryKey: queryKeys.matches });
    },
  });
}

/* ------------------------------- Premium ------------------------------- */

export function usePremiumStatus() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.premiumStatus,
    queryFn: async () => {
      if (!actor) return null;
      return actor.getPremiumStatus();
    },
    enabled: !!actor && !isFetching,
  });
}

export function usePayments() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.payments,
    queryFn: async () => {
      if (!actor) return [];
      return actor.listPayments();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useConfirmCheckout() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (sessionId: string) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.confirmCheckout(sessionId);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.premiumStatus });
      void queryClient.invalidateQueries({ queryKey: queryKeys.payments });
      void queryClient.invalidateQueries({ queryKey: queryKeys.callerProfile });
    },
  });
}

export function useStartProfileBoost() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.startProfileBoost();
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.premiumStatus });
    },
  });
}

export function useActiveAds() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.activeAds,
    queryFn: async () => {
      if (!actor) return [];
      return actor.listActiveAds();
    },
    enabled: !!actor && !isFetching,
  });
}

/* ----------------------------- Notifications --------------------------- */

export function useNotifications() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.notifications,
    queryFn: async () => {
      if (!actor) return [];
      return actor.listNotifications();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useUnreadNotificationCount() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.unreadCount,
    queryFn: async () => {
      if (!actor) return 0n;
      return actor.unreadNotificationCount();
    },
    enabled: !!actor && !isFetching,
    refetchInterval: 20000,
  });
}

export function useMarkNotificationRead() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (notificationId: Id) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.markNotificationRead(notificationId);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.notifications });
      void queryClient.invalidateQueries({ queryKey: queryKeys.unreadCount });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.markAllNotificationsRead();
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.notifications });
      void queryClient.invalidateQueries({ queryKey: queryKeys.unreadCount });
    },
  });
}

/* --------------------------------- Admin ------------------------------- */

export function useIsAdmin() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.isAdmin,
    queryFn: async () => {
      if (!actor) return false;
      return actor.isCallerAdmin();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminOverview() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.adminOverview,
    queryFn: async () => {
      if (!actor) return null;
      return actor.adminOverview();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminUsers(search: string) {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.adminUsers(search),
    queryFn: async () => {
      if (!actor) return [];
      return actor.adminListUsers(search.trim() === "" ? null : search.trim());
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminReports() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.adminReports,
    queryFn: async () => {
      if (!actor) return [];
      return actor.adminListReports();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminPayments() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.adminPayments,
    queryFn: async () => {
      if (!actor) return [];
      return actor.adminListPayments();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminSubscriptions() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.adminSubscriptions,
    queryFn: async () => {
      if (!actor) return [];
      return actor.adminListSubscriptions();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminAds() {
  const { actor, isFetching } = useActor(createActor);
  return useQuery({
    queryKey: queryKeys.adminAds,
    queryFn: async () => {
      if (!actor) return [];
      return actor.adminListAds();
    },
    enabled: !!actor && !isFetching,
  });
}

export function useAdminSetVerified() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { userId: UserId; verified: boolean }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.adminSetVerified(args.userId, args.verified);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["adminUsers"] });
    },
  });
}

export function useAdminSetBanned() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { userId: UserId; banned: boolean }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.adminSetBanned(args.userId, args.banned);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["adminUsers"] });
    },
  });
}

export function useAdminResolveReport() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { reportId: Id; status: ReportStatus }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.adminResolveReport(args.reportId, args.status);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.adminReports });
    },
  });
}

export function useAdminCreateAd() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: AdvertisementInput) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.adminCreateAd(input);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.adminAds });
      void queryClient.invalidateQueries({ queryKey: queryKeys.activeAds });
    },
  });
}

export function useAdminSetAdActive() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { adId: Id; active: boolean }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.adminSetAdActive(args.adId, args.active);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.adminAds });
      void queryClient.invalidateQueries({ queryKey: queryKeys.activeAds });
    },
  });
}

export function useAssignUserRole() {
  const { actor } = useActor(createActor);
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (args: { user: UserId; role: UserRole }) => {
      if (!actor) throw new Error("Backend is not ready");
      return actor.assignCallerUserRole(args.user, args.role);
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["adminUsers"] });
    },
  });
}
