import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_option.dart';
import '../bloc/suggest_bloc.dart';
import '../bloc/suggest_event.dart';

class MealPickerField extends StatelessWidget {
  final List<MealOption> meals;
  final String? selectedMealName;
  final bool isDark;

  const MealPickerField({
    super.key,
    required this.meals,
    required this.selectedMealName,
    required this.isDark,
  });

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SuggestBloc>(),
        child: _MealPickerSheet(meals: meals, isDark: isDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final hasSelection = selectedMealName != null;

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 20, color: textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedMealName ?? 'Select a meal',
                style: AppTextStyles.body2(
                  color: hasSelection ? textPrimary : textSecondary,
                ),
              ),
            ),
            if (hasSelection)
              GestureDetector(
                onTap: () => context
                    .read<SuggestBloc>()
                    .add(const SuggestMealCleared()),
                child: Icon(Icons.close, size: 18, color: textSecondary),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 22, color: textSecondary),
          ],
        ),
      ),
    );
  }
}

class _MealPickerSheet extends StatefulWidget {
  final List<MealOption> meals;
  final bool isDark;

  const _MealPickerSheet({required this.meals, required this.isDark});

  @override
  State<_MealPickerSheet> createState() => _MealPickerSheetState();
}

class _MealPickerSheetState extends State<_MealPickerSheet> {
  final _searchController = TextEditingController();
  List<MealOption> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.meals;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.meals
          : widget.meals
              .where((m) => m.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceBorder
                  : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              children: [
                Text(
                  'Select a Meal',
                  style: AppTextStyles.h4(color: textPrimary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                      color: textPrimary, fontFamily: 'poppins', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search meals...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                    prefixIcon:
                        Icon(Icons.search, color: textSecondary, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No meals found',
                      style: AppTextStyles.body2(color: textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: border),
                    itemBuilder: (ctx, i) {
                      final meal = _filtered[i];
                      return ListTile(
                        title: Text(
                          meal.name,
                          style: AppTextStyles.body2(color: textPrimary),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                        onTap: () {
                          context.read<SuggestBloc>().add(
                                SuggestMealSelected(
                                    id: meal.id, name: meal.name),
                              );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
