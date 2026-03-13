import 'package:goapp/features/auth/data/models/user_model.dart';

class VerifyOtpResponseModel {
  const VerifyOtpResponseModel({
    this.message,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.user,
  });

  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final UserModel? user;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic userRaw = json['user'];
    final dynamic idRaw = json['id'] ?? json['user_id'] ?? json['userId'];
    final dynamic phoneRaw = json['phone'] ?? json['mobile'] ?? json['number'];

    UserModel? parsedUser;
    if (userRaw is Map<String, dynamic>) {
      parsedUser = UserModel(
        id: (userRaw['id'] ?? userRaw['user_id'] ?? '').toString(),
        phone: (userRaw['phone'] ?? userRaw['mobile'] ?? '').toString(),
      );
    } else if (idRaw != null || phoneRaw != null) {
      parsedUser = UserModel(
        id: (idRaw ?? '').toString(),
        phone: (phoneRaw ?? '').toString(),
      );
    }

    return VerifyOtpResponseModel(
      message: (json['message'] ?? json['msg'])?.toString(),
      accessToken:
          (json['access_token'] ?? json['accessToken'] ?? json['token'])
              ?.toString(),
      refreshToken: (json['refresh_token'] ?? json['refreshToken'])?.toString(),
      tokenType: (json['token_type'] ?? json['tokenType'])?.toString(),
      expiresIn: _toInt(json['expires_in'] ?? json['expiresIn']),
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (tokenType != null) 'token_type': tokenType,
      if (expiresIn != null) 'expires_in': expiresIn,
      if (user != null)
        'user': <String, dynamic>{'id': user!.id, 'phone': user!.phone},
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
