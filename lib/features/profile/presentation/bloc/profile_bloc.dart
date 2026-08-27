import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateAvatarUseCase,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileClearError>(_onClearError);
    on<ProfileAvatarUpdateRequested>(_onAvatarUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(current.copyWith(isUpdating: true, clearError: true));

    final result = await updateProfileUseCase(
      UpdateProfileParams(fullName: event.fullName, phone: event.phone),
    );

    result.fold(
      (failure) => emit(current.copyWith(
        isUpdating: false,
        updateError: failure.message,
      )),
      (profile) => emit(current.copyWith(
        profile: profile,
        isUpdating: false,
        clearError: true,
      )),
    );
  }

  void _onClearError(
    ProfileClearError event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(clearError: true));
    }
  }

  Future<void> _onAvatarUpdateRequested(
    ProfileAvatarUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(current.copyWith(isUploadingAvatar: true, clearAvatarError: true));

    final result =
        await updateAvatarUseCase(event.bytes, event.fileExtension);

    result.fold(
      (failure) => emit(current.copyWith(
        isUploadingAvatar: false,
        avatarError: failure.message,
      )),
      (profile) => emit(current.copyWith(
        profile: profile,
        isUploadingAvatar: false,
        clearAvatarError: true,
      )),
    );
  }
}
