class UpdateProfileModel {
  final String fullName;
  final String? phone;

  const UpdateProfileModel({required this.fullName, this.phone});

  Map<String, dynamic> toAuthMetadata() => {
        'full_name': fullName,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
      };
}
