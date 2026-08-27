class ProfileEntity {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final int ratingsCount;
  final int suggestionsCount;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.phone,
    required this.ratingsCount,
    required this.suggestionsCount,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
