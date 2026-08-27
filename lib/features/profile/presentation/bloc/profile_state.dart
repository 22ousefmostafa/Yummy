import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final bool isUpdating;
  final String? updateError;
  final bool isUploadingAvatar;
  final String? avatarError;

  const ProfileLoaded({
    required this.profile,
    this.isUpdating = false,
    this.updateError,
    this.isUploadingAvatar = false,
    this.avatarError,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isUpdating,
    bool clearError = false,
    String? updateError,
    bool? isUploadingAvatar,
    bool clearAvatarError = false,
    String? avatarError,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isUpdating: isUpdating ?? this.isUpdating,
      updateError: clearError ? null : (updateError ?? this.updateError),
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      avatarError: clearAvatarError ? null : (avatarError ?? this.avatarError),
    );
  }

  @override
  List<Object?> get props => [
        profile.id,
        profile.fullName,
        profile.avatarUrl,
        profile.ratingsCount,
        isUpdating,
        updateError,
        isUploadingAvatar,
        avatarError,
      ];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
