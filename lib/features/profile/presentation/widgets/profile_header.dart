import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final bool isDark;
  final bool isUploadingAvatar;
  final VoidCallback onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isDark,
    this.isUploadingAvatar = false,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      children: [
        const SizedBox(height: 8),
        // Avatar
        Stack(
          children: [
            _AvatarCircle(
              profile: profile,
              primary: primary,
            ),
            if (isUploadingAvatar)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: isUploadingAvatar ? null : onEditAvatar,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkSurfaceBorder
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Name
        Text(
          profile.fullName.isEmpty ? 'User' : profile.fullName,
          style: AppTextStyles.h4(color: textPrimary),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          profile.email,
          style: AppTextStyles.body2(color: textSecondary),
        ),
        const SizedBox(height: 12),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatChip(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFFBA08),
              label: '${profile.ratingsCount} Ratings',
              isDark: isDark,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '|',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            _StatChip(
              icon: Icons.chat_bubble_outline,
              iconColor: primary,
              label: '${profile.suggestionsCount} Suggestions',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final ProfileEntity profile;
  final Color primary;

  const _AvatarCircle({required this.profile, required this.primary});

  @override
  Widget build(BuildContext context) {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 46,
        backgroundColor: primary,
        backgroundImage: NetworkImage(profile.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 46,
      backgroundColor: primary,
      child: Text(
        profile.initials,
        style: const TextStyle(
          fontFamily: 'poppins',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption(color: textSecondary)),
      ],
    );
  }
}
