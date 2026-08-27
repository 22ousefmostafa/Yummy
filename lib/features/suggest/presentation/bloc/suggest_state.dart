import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_option.dart';

abstract class SuggestState extends Equatable {
  const SuggestState();

  @override
  List<Object?> get props => [];
}

class SuggestInitial extends SuggestState {
  const SuggestInitial();
}

class SuggestLoading extends SuggestState {
  const SuggestLoading();
}

class SuggestLoaded extends SuggestState {
  final List<MealOption> meals;
  final String? selectedType;
  final String? selectedMealId;
  final String? selectedMealName;
  final String priority;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  const SuggestLoaded({
    required this.meals,
    this.selectedType,
    this.selectedMealId,
    this.selectedMealName,
    this.priority = 'low',
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  SuggestLoaded copyWith({
    List<MealOption>? meals,
    String? selectedType,
    bool clearType = false,
    String? selectedMealId,
    String? selectedMealName,
    bool clearMeal = false,
    String? priority,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
    bool clearError = false,
  }) {
    return SuggestLoaded(
      meals: meals ?? this.meals,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedMealId:
          clearMeal ? null : (selectedMealId ?? this.selectedMealId),
      selectedMealName:
          clearMeal ? null : (selectedMealName ?? this.selectedMealName),
      priority: priority ?? this.priority,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: clearError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [
        meals,
        selectedType,
        selectedMealId,
        selectedMealName,
        priority,
        isSubmitting,
        submitSuccess,
        submitError,
      ];
}

class SuggestError extends SuggestState {
  final String message;

  const SuggestError(this.message);

  @override
  List<Object?> get props => [message];
}
