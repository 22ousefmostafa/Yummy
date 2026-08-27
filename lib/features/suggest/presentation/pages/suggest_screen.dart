import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/suggest_bloc.dart';
import '../bloc/suggest_event.dart';
import '../bloc/suggest_state.dart';
import '../widgets/meal_picker_field.dart';
import '../widgets/priority_selector.dart';
import '../widgets/suggestion_type_card.dart';

class SuggestScreen extends StatelessWidget {
  final VoidCallback? onGoHome;

  const SuggestScreen({super.key, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SuggestBloc>()..add(const SuggestLoadRequested()),
      child: _SuggestContent(onGoHome: onGoHome),
    );
  }
}

// ─── Content (StatefulWidget for TextEditingController) ──────────────────────

class _SuggestContent extends StatefulWidget {
  final VoidCallback? onGoHome;

  const _SuggestContent({this.onGoHome});

  @override
  State<_SuggestContent> createState() => _SuggestContentState();
}

class _SuggestContentState extends State<_SuggestContent> {
  final _contentController = TextEditingController();
  final _charCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _contentController.addListener(
      () => _charCount.value = _contentController.text.length,
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _charCount.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<SuggestBloc>().add(
          SuggestSubmitRequested(content: _contentController.text),
        );
  }

  void _resetForm(BuildContext context) {
    _contentController.clear();
    context.read<SuggestBloc>().add(const SuggestReset());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<SuggestBloc, SuggestState>(
      // Clear text field when form is reset after success
      listenWhen: (prev, curr) {
        if (prev is SuggestLoaded && curr is SuggestLoaded) {
          return prev.submitSuccess && !curr.submitSuccess;
        }
        return false;
      },
      listener: (_, __) => _contentController.clear(),
      child: BlocBuilder<SuggestBloc, SuggestState>(
        builder: (context, state) {
          if (state is SuggestLoading || state is SuggestInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SuggestError) {
            return _FullErrorView(
              message: state.message,
              isDark: isDark,
              onRetry: () => context
                  .read<SuggestBloc>()
                  .add(const SuggestLoadRequested()),
            );
          }
          if (state is SuggestLoaded) {
            if (state.submitSuccess) {
              return _SuccessView(
                isDark: isDark,
                onSubmitAnother: () => _resetForm(context),
                onGoHome: widget.onGoHome ?? () {},
              );
            }
            return _SuggestForm(
              state: state,
              isDark: isDark,
              contentController: _contentController,
              charCount: _charCount,
              onSubmit: () => _submit(context),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Form ────────────────────────────────────────────────────────────────────

class _SuggestForm extends StatelessWidget {
  final SuggestLoaded state;
  final bool isDark;
  final TextEditingController contentController;
  final ValueNotifier<int> charCount;
  final VoidCallback onSubmit;

  const _SuggestForm({
    required this.state,
    required this.isDark,
    required this.contentController,
    required this.charCount,
    required this.onSubmit,
  });

  static const _types = [
    _TypeDef(
      type: 'new_dish',
      label: 'New Dish Idea',
      emoji: '🍽️',
      iconBg: Color(0xFFFFEDE8),
      iconBgDark: Color(0xFF3D1500),
    ),
    _TypeDef(
      type: 'improve_existing',
      label: 'Improve Existing Meal',
      emoji: '✏️',
      iconBg: Color(0xFFF3E8FF),
      iconBgDark: Color(0xFF2D1050),
    ),
    _TypeDef(
      type: 'service_issue',
      label: 'Service Issue',
      emoji: '🔔',
      iconBg: Color(0xFFFFFBEB),
      iconBgDark: Color(0xFF3D3000),
    ),
    _TypeDef(
      type: 'other',
      label: 'Other',
      emoji: '💬',
      iconBg: Color(0xFFECFDF5),
      iconBgDark: Color(0xFF0F3D2A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return Column(
      children: [
        // ── Header ──
        _Header(isDark: isDark, textPrimary: textPrimary),

        // ── Scrollable body ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We value your feedback!',
                  style: AppTextStyles.body2(color: textSecondary),
                ),
                const SizedBox(height: 20),

                // Suggestion Type
                _SectionLabel(label: 'Suggestion Type', isDark: isDark),
                const SizedBox(height: 10),
                ...List.generate(_types.length, (i) {
                  final t = _types[i];
                  return SuggestionTypeCard(
                    type: t.type,
                    label: t.label,
                    emoji: t.emoji,
                    iconBg: t.iconBg,
                    iconBgDark: t.iconBgDark,
                    isSelected: state.selectedType == t.type,
                    isDark: isDark,
                    onTap: () => context
                        .read<SuggestBloc>()
                        .add(SuggestTypeSelected(t.type)),
                  );
                }),

                const SizedBox(height: 20),

                // Meal picker
                _SectionLabel(
                    label: 'Which Meal? (Optional)', isDark: isDark),
                const SizedBox(height: 8),
                MealPickerField(
                  meals: state.meals,
                  selectedMealName: state.selectedMealName,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Suggestion text
                _SectionLabel(label: 'Your Suggestion', isDark: isDark),
                const SizedBox(height: 8),
                _TextArea(
                  controller: contentController,
                  charCount: charCount,
                  isDark: isDark,
                  surface: surface,
                  primary: primary,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),

                const SizedBox(height: 20),

                // Priority
                _SectionLabel(label: 'Priority', isDark: isDark),
                const SizedBox(height: 8),
                PrioritySelector(
                  selectedPriority: state.priority,
                  isDark: isDark,
                  onChanged: (p) => context
                      .read<SuggestBloc>()
                      .add(SuggestPriorityChanged(p)),
                ),

                // Error banner
                if (state.submitError != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: state.submitError!, isDark: isDark),
                ],

                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      disabledBackgroundColor: primary.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🚀',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'Send Suggestion',
                                style:
                                    AppTextStyles.button(color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Success view ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final bool isDark;
  final VoidCallback onSubmitAnother;
  final VoidCallback onGoHome;

  const _SuccessView({
    required this.isDark,
    required this.onSubmitAnother,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'Thank You!',
              style: AppTextStyles.h3(color: textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Your suggestion has been submitted\nsuccessfully and is now under review.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body2(color: textSecondary),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onSubmitAnother,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Another',
                      style: AppTextStyles.button(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onGoHome,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏠', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Home',
                      style: AppTextStyles.button(color: primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small reusable pieces ───────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;

  const _Header({required this.isDark, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share Suggestion',
                  style: AppTextStyles.h4(color: textPrimary),
                ),
                const SizedBox(width: 6),
                const Text('💡', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return Text(
      label,
      style: AppTextStyles.smallBold(color: textPrimary),
    );
  }
}

class _TextArea extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<int> charCount;
  final bool isDark;
  final Color surface;
  final Color primary;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const _TextArea({
    required this.controller,
    required this.charCount,
    required this.isDark,
    required this.surface,
    required this.primary,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 5,
          maxLength: 500,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null,
          style: TextStyle(
            fontFamily: 'poppins',
            color: textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'Share your thoughts with us...',
            hintStyle: TextStyle(
              fontFamily: 'poppins',
              color: textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<int>(
            valueListenable: charCount,
            builder: (_, count, __) => Text(
              '$count/500',
              style: AppTextStyles.caption(
                color: count > 500 ? AppColors.error : textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;

  const _ErrorBanner({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:
                  AppTextStyles.caption(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _FullErrorView({
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
          Text(message,
              style: AppTextStyles.body2(color: textSecondary),
              textAlign: TextAlign.center),
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

// Helper data class for type options (pure config, no state)
class _TypeDef {
  final String type;
  final String label;
  final String emoji;
  final Color iconBg;
  final Color iconBgDark;

  const _TypeDef({
    required this.type,
    required this.label,
    required this.emoji,
    required this.iconBg,
    required this.iconBgDark,
  });
}
