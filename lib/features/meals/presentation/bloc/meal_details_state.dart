import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_entity.dart';

abstract class MealDetailsState extends Equatable {
  const MealDetailsState();
  @override
  List<Object?> get props => [];
}

class MealDetailsInitial extends MealDetailsState {
  const MealDetailsInitial();
}

class MealDetailsLoading extends MealDetailsState {
  const MealDetailsLoading();
}

class MealDetailsLoaded extends MealDetailsState {
  final MealDetailEntity meal;
  final bool isFavorite;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  const MealDetailsLoaded({
    required this.meal,
    this.isFavorite = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  MealDetailsLoaded copyWith({
    MealDetailEntity? meal,
    bool? isFavorite,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
    bool clearError = false,
  }) {
    return MealDetailsLoaded(
      meal: meal ?? this.meal,
      isFavorite: isFavorite ?? this.isFavorite,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: clearError ? null : submitError ?? this.submitError,
    );
  }

  @override
  List<Object?> get props =>
      [meal, isFavorite, isSubmitting, submitSuccess, submitError];
}

class MealDetailsError extends MealDetailsState {
  final String message;
  const MealDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}
