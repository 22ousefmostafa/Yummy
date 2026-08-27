import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_bloc/theme_bloc.dart';
import '../bloc/profile_state.dart';

class SettingsMenu extends StatelessWidget {
  final ProfileLoaded profileState;
  final bool isDark;
  final VoidCallback onEditProfile;
  final VoidCallback onFavorites;
  final VoidCallback onNotifications;
  final VoidCallback onTerms;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  const SettingsMenu({
    super.key,
    required this.profileState,
    required this.isDark,
    required this.onEditProfile,
    required this.onFavorites,
    required this.onNotifications,
    required this.onTerms,
    required this.onAbout,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ACCOUNT section
        _SectionLabel(label: 'ACCOUNT', isDark: isDark),
        const SizedBox(height: 8),
        _SettingsCard(
          isDark: isDark,
          children: [
            _MenuItem(
              iconBg: const Color(0xFFEEF2FF),
              iconBgDark: const Color(0xFF1E2050),
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF6366F1),
              label: 'Edit Profile',
              isDark: isDark,
              onTap: onEditProfile,
            ),
            _Divider(isDark: isDark),
            _MenuItem(
              iconBg: const Color(0xFFFFF0F0),
              iconBgDark: const Color(0xFF3D1515),
              icon: Icons.favorite_outline_rounded,
              iconColor: const Color(0xFFEF4444),
              label: 'My Favorites',
              isDark: isDark,
              onTap: onFavorites,
            ),
            _Divider(isDark: isDark),
            _MenuItem(
              iconBg: const Color(0xFFFFFBEB),
              iconBgDark: const Color(0xFF3D3000),
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFF59E0B),
              label: 'Notifications',
              isDark: isDark,
              onTap: onNotifications,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // PREFERENCES section
        _SectionLabel(label: 'PREFERENCES', isDark: isDark),
        const SizedBox(height: 8),
        _SettingsCard(
          isDark: isDark,
          children: [
            // Dark mode toggle
            _DarkModeItem(isDark: isDark, textSecondary: textSecondary),
          ],
        ),

        const SizedBox(height: 20),

        // ABOUT section
        _SectionLabel(label: 'ABOUT', isDark: isDark),
        const SizedBox(height: 8),
        _SettingsCard(
          isDark: isDark,
          children: [
            _MenuItem(
              iconBg: const Color(0xFFF3E8FF),
              iconBgDark: const Color(0xFF2D1050),
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF8B5CF6),
              label: 'Terms & Privacy Policy',
              isDark: isDark,
              onTap: onTerms,
            ),
            _Divider(isDark: isDark),
            _MenuItem(
              iconBg: const Color(0xFFEFF6FF),
              iconBgDark: const Color(0xFF0F2A50),
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF3B82F6),
              label: 'About YumUp',
              isDark: isDark,
              onTap: onAbout,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Text('🚪', style: TextStyle(fontSize: 18)),
            label: Text(
              'Logout',
              style: AppTextStyles.button(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Text(
      label,
      style: AppTextStyles.caption(color: textSecondary).copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Container(
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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: isDark ? AppColors.darkSurfaceBorder : const Color(0xFFF3F4F6),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Color iconBg;
  final Color iconBgDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.iconBg,
    required this.iconBgDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? iconBgDark : iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body2(color: textPrimary)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkModeItem extends StatelessWidget {
  final bool isDark;
  final Color textSecondary;

  const _DarkModeItem({
    required this.isDark,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1A3D)
                      : const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dark_mode_outlined,
                  color: Color(0xFF6366F1),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Dark Mode',
                  style: AppTextStyles.body2(color: textPrimary)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: themeState.isDarkMode
                        ? textSecondary
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Switch(
                    value: themeState.isDarkMode,
                    onChanged: (_) => context
                        .read<ThemeBloc>()
                        .add(const ToggleThemeEvent()),
                    activeThumbColor: Colors.white,
                    activeTrackColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.dark_mode_outlined,
                    size: 16,
                    color: themeState.isDarkMode
                        ? const Color(0xFF6366F1)
                        : textSecondary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
