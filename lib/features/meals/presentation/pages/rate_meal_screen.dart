import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entity.dart';
import '../bloc/meal_details_bloc.dart';
import '../bloc/meal_details_event.dart';
import '../bloc/meal_details_state.dart';

class RateMealScreen extends StatefulWidget {
  final String mealId;
  final String mealName;
  final String categoryName;
  final String? imageUrl;

  const RateMealScreen({
    super.key,
    required this.mealId,
    required this.mealName,
    required this.categoryName,
    this.imageUrl,
  });

  @override
  State<RateMealScreen> createState() => _RateMealScreenState();
}

class _RateMealScreenState extends State<RateMealScreen> {
  int _tasteScore = 0;
  int _presentationScore = 0;
  double _portionScore = 3.0;
  double _valueScore = 3.5;
  final _reviewController = TextEditingController();
  final _charNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _reviewController.addListener(() {
      _charNotifier.value = _reviewController.text.length;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _charNotifier.dispose();
    super.dispose();
  }

  double get _overallScore =>
      (_tasteScore + _presentationScore + _portionScore.round() + _valueScore.round()) / 4.0;

  bool get _canSubmit => _tasteScore > 0 && _presentationScore > 0;

  void _submit(BuildContext context) {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please rate Taste and Presentation to continue.')),
      );
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['full_name'] as String?) ?? 'Anonymous';

    context.read<MealDetailsBloc>().add(
          MealDetailsRatingSubmitted(
            SubmitRatingParams(
              mealId: widget.mealId,
              tasteScore: _tasteScore,
              presentationScore: _presentationScore,
              portionScore: _portionScore.round(),
              valueScore: _valueScore.round(),
              comment: _reviewController.text.trim().isEmpty
                  ? null
                  : _reviewController.text.trim(),
              reviewerName: name,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return BlocListener<MealDetailsBloc, MealDetailsState>(
      listenWhen: (prev, curr) {
        if (prev is MealDetailsLoaded && curr is MealDetailsLoaded) {
          return prev.isSubmitting && !curr.isSubmitting;
        }
        return false;
      },
      listener: (context, state) {
        if (state is MealDetailsLoaded) {
          if (state.submitSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Rating submitted! Thank you.'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state.submitError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.submitError!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Rate Meal',
              style: AppTextStyles.h4(color: textPrimary)),
          centerTitle: false,
        ),
        body: BlocBuilder<MealDetailsBloc, MealDetailsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal info card
                  _MealInfoCard(
                    name: widget.mealName,
                    categoryName: widget.categoryName,
                    imageUrl: widget.imageUrl,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Taste
                  _SectionLabel(
                      icon: '🍴',
                      label: 'How was the taste?',
                      isDark: isDark),
                  const SizedBox(height: 12),
                  _TasteSelector(
                    selected: _tasteScore,
                    onChanged: (v) => setState(() => _tasteScore = v),
                    primary: primary,
                  ),
                  const SizedBox(height: 24),

                  // Presentation
                  _SectionLabel(
                      icon: '🎨',
                      label: 'Presentation',
                      isDark: isDark),
                  const SizedBox(height: 12),
                  _StarRatingRow(
                    score: _presentationScore,
                    onChanged: (v) =>
                        setState(() => _presentationScore = v),
                    primary: primary,
                  ),
                  const SizedBox(height: 24),

                  // Portion size
                  _SectionLabel(
                      icon: '🍽️', label: 'Portion Size', isDark: isDark),
                  const SizedBox(height: 8),
                  _SliderRow(
                    value: _portionScore,
                    leftLabel: 'Small',
                    rightLabel: 'Perfect',
                    isDark: isDark,
                    primary: primary,
                    onChanged: (v) => setState(() => _portionScore = v),
                  ),
                  const SizedBox(height: 24),

                  // Value for money
                  _SectionLabel(
                      icon: '💰',
                      label: 'Value for Money',
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _SliderRow(
                    value: _valueScore,
                    leftLabel: 'Overpriced',
                    rightLabel: 'Great Deal',
                    isDark: isDark,
                    primary: primary,
                    onChanged: (v) => setState(() => _valueScore = v),
                  ),
                  const SizedBox(height: 24),

                  // Add photo placeholder
                  _SectionLabel(
                      icon: '📷',
                      label: 'Add Photo (Optional)',
                      isDark: isDark),
                  const SizedBox(height: 10),
                  _PhotoPlaceholder(isDark: isDark),
                  const SizedBox(height: 24),

                  // Review text
                  _SectionLabel(
                      icon: '💬',
                      label: 'Your Review (Optional)',
                      isDark: isDark),
                  const SizedBox(height: 10),
                  _ReviewTextArea(
                    controller: _reviewController,
                    charNotifier: _charNotifier,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Overall rating card
                  _OverallRatingCard(
                    overall: _overallScore,
                    isDark: isDark,
                    primary: primary,
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<MealDetailsBloc, MealDetailsState>(
          builder: (context, state) {
            final isSubmitting =
                state is MealDetailsLoaded && state.isSubmitting;
            final isDarkMode =
                Theme.of(context).brightness == Brightness.dark;
            final p =
                isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
            final bgColor =
                isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

            return Container(
              color: bgColor,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p,
                    disabledBackgroundColor: p.withAlpha(128),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Submit Rating',
                          style: AppTextStyles.button(color: Colors.white)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MealInfoCard extends StatelessWidget {
  final String name;
  final String categoryName;
  final String? imageUrl;
  final bool isDark;

  const _MealInfoCard({
    required this.name,
    required this.categoryName,
    required this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final imgBg =
        isDark ? const Color(0xFF252545) : const Color(0xFFF3F4F6);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: border, width: 1) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: imgBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null
                  ? Image.network(imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                            child: Text('🍽️',
                                style: TextStyle(fontSize: 24)),
                          ))
                  : const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 24))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body1(color: textPrimary)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(categoryName,
                    style: AppTextStyles.caption(color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String icon;
  final String label;
  final bool isDark;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.small(color: textPrimary)
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TasteSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final Color primary;

  static const _emojis = ['😡', '😟', '😐', '😊', '🤩'];

  const _TasteSelector({
    required this.selected,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final val = i + 1;
        final isSelected = selected == val;
        return GestureDetector(
          onTap: () => onChanged(val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? primary.withAlpha(30) : Colors.transparent,
              border: isSelected
                  ? Border.all(color: primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                _emojis[i],
                style: TextStyle(fontSize: isSelected ? 28 : 24),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  final int score;
  final ValueChanged<int> onChanged;
  final Color primary;

  const _StarRatingRow({
    required this.score,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final val = i + 1;
        final filled = val <= score;
        return GestureDetector(
          onTap: () => onChanged(val),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 36,
              color: filled ? AppColors.lightAccent : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final double value;
  final String leftLabel;
  final String rightLabel;
  final bool isDark;
  final Color primary;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.value,
    required this.leftLabel,
    required this.rightLabel,
    required this.isDark,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: 'poppins',
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: primary,
            inactiveTrackColor:
                isDark ? const Color(0xFF252545) : const Color(0xFFE5E7EB),
            thumbColor: primary,
            overlayColor: primary.withAlpha(30),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            onChanged: onChanged,
          ),
        ),
        Row(
          children: [
            Text(leftLabel,
                style: AppTextStyles.caption(color: textSecondary)),
            const Spacer(),
            Text(rightLabel,
                style: AppTextStyles.caption(color: textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final bool isDark;

  const _PhotoPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFD1D5DB);

    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: border, width: 1.5, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 28, color: textSecondary),
          const SizedBox(height: 6),
          Text('Tap to add photo',
              style: AppTextStyles.caption(color: textSecondary)),
        ],
      ),
    );
  }
}

class _ReviewTextArea extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<int> charNotifier;
  final bool isDark;

  const _ReviewTextArea({
    required this.controller,
    required this.charNotifier,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 300,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null,
          style: TextStyle(
              color: textPrimary, fontFamily: 'poppins', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Tell us about your experience...',
            hintStyle: TextStyle(color: textSecondary, fontSize: 14),
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
              borderSide: BorderSide(color: primary),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<int>(
            valueListenable: charNotifier,
            builder: (_, count, __) => Text(
              '$count/300',
              style: AppTextStyles.caption(color: textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverallRatingCard extends StatelessWidget {
  final double overall;
  final bool isDark;
  final Color primary;

  const _OverallRatingCard({
    required this.overall,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withAlpha(60), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🏅', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('Overall Rating',
                  style: AppTextStyles.small(color: textPrimary)
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${overall.toStringAsFixed(1)} / 5.0',
            style: AppTextStyles.h3(color: textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              final filled = i < overall.round();
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 20,
                  color: filled ? primary : Colors.grey[400],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
