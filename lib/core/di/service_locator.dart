import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cache/hive_cache_service.dart';
import '../network/connectivity_provider.dart';
import '../network/network_info.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/favorites/data/datasources/favorites_remote_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/data/datasources/home_remote_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_featured_meals_usecase.dart';
import '../../features/home/domain/usecases/get_popular_meals_usecase.dart';
import '../../features/home/domain/usecases/get_recent_ratings_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/history/data/datasources/history_remote_source.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/delete_rating_usecase.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/notifications/data/datasources/notifications_remote_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_as_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_as_read_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/suggest/data/datasources/suggest_remote_source.dart';
import '../../features/suggest/data/repositories/suggest_repository_impl.dart';
import '../../features/suggest/domain/repositories/suggest_repository.dart';
import '../../features/suggest/domain/usecases/get_meals_for_suggest_usecase.dart';
import '../../features/suggest/domain/usecases/submit_suggestion_usecase.dart';
import '../../features/suggest/presentation/bloc/suggest_bloc.dart';
import '../../features/meals/data/datasources/meals_remote_source.dart';
import '../../features/meals/data/repositories/meals_repository_impl.dart';
import '../../features/meals/domain/repositories/meals_repository.dart';
import '../../features/meals/domain/usecases/get_meals_usecase.dart';
import '../../features/meals/domain/usecases/get_meal_details_usecase.dart';
import '../../features/meals/domain/usecases/get_categories_usecase.dart';
import '../../features/meals/domain/usecases/search_meals_usecase.dart';
import '../../features/meals/presentation/bloc/meals_bloc.dart';
import '../../features/meals/presentation/bloc/meal_details_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_avatar_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../storage/app_preferences.dart';
import '../storage/preferences_service.dart';
import '../theme/theme_bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService(sl()));
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Connectivity + offline cache
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<HiveCacheService>(() => HiveCacheService());
  sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(sl()));

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUserUseCase: sl(),
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Home
  sl.registerLazySingleton<HomeRemoteSource>(
    () => HomeRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl(), cache: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetPopularMealsUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedMealsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentRatingsUseCase(sl()));
  sl.registerFactory(
    () => HomeBloc(
      getCategoriesUseCase: sl(),
      getPopularMealsUseCase: sl(),
      getFeaturedMealsUseCase: sl(),
      getRecentRatingsUseCase: sl(),
      mealsRepository: sl(),
      supabaseClient: sl(),
    ),
  );

  // History
  sl.registerLazySingleton<HistoryRemoteSource>(
    () => HistoryRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl(), cache: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRatingUseCase(sl()));

  // Suggest
  sl.registerLazySingleton<SuggestRemoteSource>(
    () => SuggestRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<SuggestRepository>(
    () => SuggestRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMealsForSuggestUseCase(sl()));
  sl.registerLazySingleton(() => SubmitSuggestionUseCase(sl()));
  sl.registerFactory(
    () => SuggestBloc(
      getMealsUseCase: sl(),
      submitSuggestionUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => HistoryBloc(
      getHistoryUseCase: sl(),
      deleteRatingUseCase: sl(),
      suggestRepository: sl(),
    ),
  );

  // Meals
  sl.registerLazySingleton<MealsRemoteSource>(
    () => MealsRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<MealsRepository>(
    () => MealsRepositoryImpl(sl(), cache: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetMealsUseCase(sl()));
  sl.registerLazySingleton(() => GetMealDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetMealCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => SearchMealsUseCase());
  sl.registerFactory(
    () => MealsBloc(
      getMealsUseCase: sl(),
      getCategoriesUseCase: sl(),
      searchMealsUseCase: sl(),
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => MealDetailsBloc(
      getMealDetailsUseCase: sl(),
      repository: sl(),
    ),
  );

  // Profile
  sl.registerLazySingleton<ProfileRemoteSource>(
    () => ProfileRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateAvatarUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );

  // Favorites
  sl.registerLazySingleton<FavoritesRemoteSource>(
    () => FavoritesRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl(), cache: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerFactory(
    () => FavoritesBloc(
      getFavoritesUseCase: sl(),
      mealsRepository: sl(),
    ),
  );

  // Notifications
  sl.registerLazySingleton<NotificationsRemoteSource>(
    () => NotificationsRemoteSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllAsReadUseCase(sl()));
  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllAsReadUseCase: sl(),
    ),
  );

  // Theme
  sl.registerFactory(
    () => ThemeBloc(
      appPreferences: sl(),
    ),
  );
}
