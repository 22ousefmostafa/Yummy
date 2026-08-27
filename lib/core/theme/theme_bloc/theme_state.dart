part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({
    this.isDarkMode = false,
  });

  @override
  List<Object?> get props => [isDarkMode];
}
