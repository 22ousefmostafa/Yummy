import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../storage/app_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final AppPreferences appPreferences;

  ThemeBloc({
    required this.appPreferences,
  }) : super(
          ThemeState(
            isDarkMode: appPreferences.getThemeMode() == 'dark',
          ),
        ) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final nextIsDarkMode = !state.isDarkMode;

    await appPreferences.setThemeMode(
      nextIsDarkMode ? 'dark' : 'light',
    );

    emit(ThemeState(isDarkMode: nextIsDarkMode));
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await appPreferences.setThemeMode(
      event.isDarkMode ? 'dark' : 'light',
    );

    emit(ThemeState(isDarkMode: event.isDarkMode));
  }
}