import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String userName;
  final List<PromoBannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<MealEntity> popularMeals;
  final List<RecentRatingEntity> recentRatings;

  const HomeLoaded({
    required this.userName,
    required this.banners,
    required this.categories,
    required this.popularMeals,
    required this.recentRatings,
  });

  HomeLoaded copyWith({List<MealEntity>? popularMeals}) => HomeLoaded(
        userName: userName,
        banners: banners,
        categories: categories,
        popularMeals: popularMeals ?? this.popularMeals,
        recentRatings: recentRatings,
      );

  @override
  List<Object?> get props => [
        userName,
        banners,
        categories,
        popularMeals,
        recentRatings,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
