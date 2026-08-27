import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../favorites/presentation/pages/favorites_screen.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_menu.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      children: [
        // Custom AppBar
        Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h4(color: textPrimary),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (prev, curr) {
              if (prev is ProfileLoaded && curr is ProfileLoaded) {
                return (prev.isUpdating && !curr.isUpdating) ||
                    (prev.isUploadingAvatar && !curr.isUploadingAvatar);
              }
              return false;
            },
            listener: (context, state) {
              if (state is! ProfileLoaded) return;
              if (state.updateError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.updateError!)),
                );
              } else if (state.avatarError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.avatarError!)),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProfileError) {
                return _ErrorView(
                  message: state.message,
                  isDark: isDark,
                  onRetry: () => context
                      .read<ProfileBloc>()
                      .add(const ProfileLoadRequested()),
                );
              }
              if (state is ProfileLoaded) {
                return _ProfileBody(state: state, isDark: isDark);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ProfileLoaded state;
  final bool isDark;

  const _ProfileBody({required this.state, required this.isDark});

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AvatarSourceSheet(isDark: isDark),
    );
    if (source == null || !context.mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.path.contains('.')
        ? picked.path.split('.').last.toLowerCase()
        : 'jpg';
    if (!context.mounted) return;

    context.read<ProfileBloc>().add(
          ProfileAvatarUpdateRequested(bytes: bytes, fileExtension: ext),
        );
  }

  void _pushEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: const EditProfileScreen(),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terms & Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'By using YumUp, you agree to our Terms of Service.\n\n'
            'We collect only the data necessary to provide our service. '
            'Your meal ratings and suggestions are stored securely and are '
            'never shared with third parties without your consent.\n\n'
            'For questions, contact support@yumup.app.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'YumUp',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('🍽️', style: TextStyle(fontSize: 24)),
        ),
      ),
      children: const [
        Text(
          'YumUp helps you discover, rate, and suggest meals at your campus cafeteria.',
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ProfileHeader(
            profile: state.profile,
            isDark: isDark,
            isUploadingAvatar: state.isUploadingAvatar,
            onEditAvatar: () => _pickAndUploadAvatar(context),
          ),
          const SizedBox(height: 24),
          SettingsMenu(
            profileState: state,
            isDark: isDark,
            onEditProfile: () => _pushEditProfile(context),
            onFavorites: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
            onNotifications: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<NotificationsBloc>(),
                  child: const NotificationsScreen(),
                ),
              ),
            ),
            onTerms: () => _showTermsDialog(context),
            onAbout: () => _showAboutDialog(context),
            onLogout: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

class _AvatarSourceSheet extends StatelessWidget {
  final bool isDark;

  const _AvatarSourceSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceBorder
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Update Profile Photo',
              style: AppTextStyles.h4(color: textPrimary),
            ),
            const SizedBox(height: 16),
            _SourceTile(
              icon: Icons.photo_camera_outlined,
              label: 'Take Photo',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textSecondary),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body2(color: textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body2(color: textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text('Try again',
                style: AppTextStyles.smallBold(color: primary)),
          ),
        ],
      ),
    );
  }
}
