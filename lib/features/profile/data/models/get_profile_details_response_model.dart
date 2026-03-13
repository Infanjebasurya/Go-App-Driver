import 'package:goapp/features/profile/data/models/profile_model.dart';

class GetProfileDetailsResponseModel {
  const GetProfileDetailsResponseModel({
    required this.profile,
    this.message,
    this.success,
  });

  final ProfileModel profile;
  final String? message;
  final bool? success;

  factory GetProfileDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic profileRaw = json['data'] ?? json['profile'] ?? json;
    final profileJson = profileRaw is Map<String, dynamic>
        ? profileRaw
        : <String, dynamic>{};

    return GetProfileDetailsResponseModel(
      profile: ProfileModel.fromJson(profileJson),
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': profile.toJson(),
      if (message != null) 'message': message,
      if (success != null) 'success': success,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'success') return true;
      if (normalized == 'false' || normalized == 'failed') return false;
    }
    return null;
  }
}
