import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String fullName;
  final String? phone;

  const ProfileUpdateRequested({required this.fullName, this.phone});

  @override
  List<Object?> get props => [fullName, phone];
}

class ProfileClearError extends ProfileEvent {
  const ProfileClearError();
}

class ProfileAvatarUpdateRequested extends ProfileEvent {
  final Uint8List bytes;
  final String fileExtension;

  const ProfileAvatarUpdateRequested({
    required this.bytes,
    required this.fileExtension,
  });

  @override
  List<Object?> get props => [bytes, fileExtension];
}
