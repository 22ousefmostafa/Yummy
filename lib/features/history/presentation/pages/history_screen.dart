import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../domain/entities/history_entity.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_tab_bar.dart';
import '../widgets/rating_history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryBloc>()..add(const HistoryLoadRequested()),
      child: const _HistoryContent(),
    );
  }
}

class _DeleteResultListener extends StatelessWidget {
  final Widget child;

  const _DeleteResultListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistoryBloc, HistoryState>(
      listenWhen: (prev, curr) {
        if (prev is! HistoryLoaded || curr is! HistoryLoaded) return false;
        return prev.ratings.length != curr.ratings.length ||
            prev.deleteError != curr.deleteError;
      },
      listener: (context, state) {
        if (state is! HistoryLoaded) return;
        if (state.deleteError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.deleteError!),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Rating deleted'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () =>
                    context.read<HistoryBloc>().add(const HistoryLoadRequested()),
              ),
            ),
          );
        }
      },
      child: child,
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DeleteResultListener(
      child: BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            _HistoryHeader(isDark: isDark),
            const OfflineBanner(),
            if (state is HistoryLoaded)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: HistoryTabBar(
                  activeTab: state.activeTab,
                  onTabChanged: (tab) =>
                      context.read<HistoryBloc>().add(HistoryTabChanged(tab)),
                ),
              ),
            Expanded(
              child: _buildBody(context, state, isDark),
            ),
          ],
        );
      },
    ),
    );
  }

  Widget _buildBody(
      BuildContext context, HistoryState state, bool isDark) {
    if (state is HistoryLoading || state is HistoryInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is HistoryError) {
      return _ErrorView(
        message: state.message,
        isDark: isDark,
        onRetry: () =>
            context.read<HistoryBloc>().add(const HistoryLoadRequested()),
      );
    }
    if (state is HistoryLoaded) {
      if (state.activeTab == 0) {
        return _RatingsList(ratings: state.ratings, isDark: isDark);
      } else {
        return _SuggestionsList(
            suggestions: state.suggestions, isDark: isDark);
      }
    }
    return const SizedBox.shrink();
  }
}

class _HistoryHeader extends StatelessWidget {
  final bool isDark;

  const _HistoryHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: textPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              'My History',
              textAlign: TextAlign.center,
              style: AppTextStyles.h4(color: textPrimary),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, size: 22, color: textPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Ratings list ────────────────────────────────────────────────────────────

class _RatingsList extends StatelessWidget {
  final List<RatingHistoryEntity> ratings;
  final bool isDark;

  const _RatingsList({required this.ratings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) {
      return _EmptyView(
        emoji: '⭐',
        title: 'No ratings yet',
        subtitle: 'Your meal ratings will appear here',
        isDark: isDark,
      );
    }

    final now = DateTime.now();
    final thisWeekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final thisWeek =
        ratings.where((r) => r.createdAt.isAfter(thisWeekStart)).toList();
    final lastWeek = ratings
        .where((r) =>
            r.createdAt.isAfter(lastWeekStart) &&
            !r.createdAt.isAfter(thisWeekStart))
        .toList();
    final earlier =
        ratings.where((r) => !r.createdAt.isAfter(lastWeekStart)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
      children: [
        if (thisWeek.isNotEmpty) ...[
          _SectionHeader(label: 'This Week', isDark: isDark),
          ...thisWeek
              .map((r) => _RatingCardWrapper(rating: r, isDark: isDark)),
        ],
        if (lastWeek.isNotEmpty) ...[
          _SectionHeader(label: 'Last Week', isDark: isDark),
          ...lastWeek
              .map((r) => _RatingCardWrapper(rating: r, isDark: isDark)),
        ],
        if (earlier.isNotEmpty) ...[
          _SectionHeader(label: 'Earlier', isDark: isDark),
          ...earlier
              .map((r) => _RatingCardWrapper(rating: r, isDark: isDark)),
        ],
      ],
    );
  }
}

class _RatingCardWrapper extends StatelessWidget {
  final RatingHistoryEntity rating;
  final bool isDark;

  const _RatingCardWrapper({required this.rating, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RatingHistoryCard(
      rating: rating,
      isDark: isDark,
      onEdit: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit rating — coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onDelete: () {
        context
            .read<HistoryBloc>()
            .add(HistoryRatingDeleteRequested(rating.id));
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label, style: AppTextStyles.smallBold(color: primary)),
    );
  }
}

// ─── Suggestions list ────────────────────────────────────────────────────────

class _SuggestionsList extends StatelessWidget {
  final List<SuggestionHistoryEntity> suggestions;
  final bool isDark;

  const _SuggestionsList({required this.suggestions, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return _EmptyView(
        emoji: '💬',
        title: 'No suggestions yet',
        subtitle: 'Your meal suggestions will appear here',
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemCount: suggestions.length,
      itemBuilder: (_, i) =>
          _SuggestionCard(suggestion: suggestions[i], isDark: isDark),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SuggestionHistoryEntity suggestion;
  final bool isDark;

  const _SuggestionCard({required this.suggestion, required this.isDark});

  static const _steps = ['Sent', 'Under Review', 'In Progress', 'Done'];

  static const _typeEmojis = {
    'new_dish': '🍽️',
    'improve_existing': '✏️',
    'service_issue': '🔔',
    'other': '💬',
  };

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'under_review': Color(0xFF3B82F6),
    'in_progress': Color(0xFF8B5CF6),
    'done': Color(0xFF10B981),
    'rejected': Color(0xFFEF4444),
  };

  static const _statusLabels = {
    'pending': 'Pending',
    'under_review': 'Under Review',
    'in_progress': 'In Progress',
    'done': 'Done',
    'rejected': 'Rejected',
  };

  int get _activeStep {
    switch (suggestion.status) {
      case 'under_review':
        return 1;
      case 'in_progress':
        return 2;
      case 'done':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final statusColor =
        _statusColors[suggestion.status] ?? const Color(0xFF6B7280);
    final statusLabel =
        _statusLabels[suggestion.status] ?? suggestion.status;
    final typeEmoji = _typeEmojis[suggestion.type] ?? '💬';
    final isRejected = suggestion.status == 'rejected';
    final title = suggestion.mealName ??
        (suggestion.content.length > 40
            ? '${suggestion.content.substring(0, 40)}…'
            : suggestion.content);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? Border.all(color: AppColors.darkSurfaceBorder, width: 1)
            : null,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF252550)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        Text(typeEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.smallBold(color: textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: AppTextStyles.caption(color: statusColor)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(suggestion.createdAt),
                            style: AppTextStyles.caption(color: textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isRejected) ...[
              const SizedBox(height: 14),
              _ProgressDots(
                steps: _steps,
                activeStep: _activeStep,
                activeColor: primary,
                isDark: isDark,
              ),
            ],
            if (isRejected) ...[
              const SizedBox(height: 10),
              Text(
                'Your suggestion was reviewed but not approved at this time.',
                style: AppTextStyles.caption(color: textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

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
    return 'Just now';
  }
}

class _ProgressDots extends StatelessWidget {
  final List<String> steps;
  final int activeStep;
  final Color activeColor;
  final bool isDark;

  const _ProgressDots({
    required this.steps,
    required this.activeStep,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inactive =
        isDark ? const Color(0xFF2D2D5E) : const Color(0xFFE5E7EB);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = index ~/ 2;
              final done = stepIndex < activeStep;
              return Expanded(
                child: Container(height: 2, color: done ? activeColor : inactive),
              );
            }
            final dotIndex = index ~/ 2;
            final done = dotIndex <= activeStep;
            return Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: done ? activeColor : inactive,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((e) {
            final isActive = e.key <= activeStep;
            return Text(
              e.value,
              style: AppTextStyles.caption(
                color: isActive ? activeColor : textSecondary,
              ).copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyView({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h4(color: textPrimary)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body2(color: textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
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
            child:
                Text('Try again', style: AppTextStyles.smallBold(color: primary)),
          ),
        ],
      ),
    );
  }
}
