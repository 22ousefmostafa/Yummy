import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

/// Assumes a [NotificationsBloc] is already provided above it in the tree
/// (see [HomePage], which owns the shared instance so the unread badge and
/// this screen stay in sync).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsHeader(isDark: isDark),
            Expanded(
              child: BlocConsumer<NotificationsBloc, NotificationsState>(
                listenWhen: (_, curr) =>
                    curr is NotificationsLoaded && curr.actionError != null,
                listener: (context, state) {
                  if (state is NotificationsLoaded &&
                      state.actionError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.actionError!)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is NotificationsLoading ||
                      state is NotificationsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is NotificationsError) {
                    return _ErrorView(
                      message: state.message,
                      isDark: isDark,
                      onRetry: () => context
                          .read<NotificationsBloc>()
                          .add(const NotificationsLoadRequested()),
                    );
                  }
                  if (state is NotificationsLoaded) {
                    if (state.notifications.isEmpty) {
                      return _EmptyView(isDark: isDark);
                    }
                    return _NotificationsList(
                      notifications: state.notifications,
                      isDark: isDark,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final bool isDark;

  const _NotificationsHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: textPrimary),
          ),
          Expanded(
            child: Text(
              'Notifications',
              style: AppTextStyles.h4(color: textPrimary),
            ),
          ),
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationsLoaded && state.unreadCount > 0;
              return TextButton(
                onPressed: hasUnread
                    ? () => context
                        .read<NotificationsBloc>()
                        .add(const NotificationsMarkAllReadRequested())
                    : null,
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.smallBold(
                    color: hasUnread ? primary : textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Notification list ───────────────────────────────────────────────────────

class _NotificationsList extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final bool isDark;

  const _NotificationsList({
    required this.notifications,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final today =
        notifications.where((n) => !n.createdAt.isBefore(todayStart)).toList();
    final yesterday = notifications
        .where((n) =>
            n.createdAt.isBefore(todayStart) &&
            !n.createdAt.isBefore(yesterdayStart))
        .toList();
    final earlier = notifications
        .where((n) => n.createdAt.isBefore(yesterdayStart))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (today.isNotEmpty) ...[
          _SectionHeader(label: 'Today', isDark: isDark),
          ...today
              .map((n) => _NotificationCard(notification: n, isDark: isDark)),
        ],
        if (yesterday.isNotEmpty) ...[
          _SectionHeader(label: 'Yesterday', isDark: isDark),
          ...yesterday
              .map((n) => _NotificationCard(notification: n, isDark: isDark)),
        ],
        if (earlier.isNotEmpty) ...[
          _SectionHeader(label: 'Earlier', isDark: isDark),
          ...earlier
              .map((n) => _NotificationCard(notification: n, isDark: isDark)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondary =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
      child: Text(label, style: AppTextStyles.smallBold(color: secondary)),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final bool isDark;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
  });

  static const _typeIcons = {
    'suggestion_updated': '✅',
    'new_meal': '🍔',
    'rating_confirmed': '⭐',
    'weekend_special': '📣',
    'new_comment': '💬',
  };

  static const _typeColors = {
    'suggestion_updated': Color(0xFF10B981),
    'new_meal': Color(0xFFF97316),
    'rating_confirmed': Color(0xFFF59E0B),
    'weekend_special': Color(0xFFEF4444),
    'new_comment': Color(0xFF2EC4B6),
  };

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unreadTint =
        isDark ? const Color(0xFF2A1F14) : const Color(0xFFFFF3E8);
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accent = _typeColors[notification.type] ?? primary;
    final icon = _typeIcons[notification.type] ?? '🔔';
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          context
              .read<NotificationsBloc>()
              .add(NotificationMarkReadRequested(notification.id));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUnread ? unreadTint : surface,
          borderRadius: BorderRadius.circular(14),
          // A Border's colors must be uniform when paired with a
          // borderRadius, so the left accent (unread) and the dark-mode
          // outline (read) are mutually exclusive rather than combined.
          border: isUnread
              ? Border(left: BorderSide(color: accent, width: 4))
              : (isDark
                  ? Border.all(color: AppColors.darkSurfaceBorder, width: 1)
                  : null),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.smallBold(color: textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      style: AppTextStyles.caption(color: textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: AppTextStyles.caption(color: textSecondary),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool isDark;

  const _EmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔔', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: AppTextStyles.h4(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll let you know when something new happens.',
              style: AppTextStyles.body2(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body2(color: textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text('Try again',
                style: AppTextStyles.smallBold(color: primary)),
          ),
        ],
      ),
    );
  }
}
