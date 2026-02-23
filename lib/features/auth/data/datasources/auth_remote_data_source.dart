import 'package:goapp/features/auth/data/models/user_model.dart';

class AuthResponse {
  const AuthResponse({
    required this.user,
  });

  final UserModel user;
}

abstract interface class AuthRemoteDataSource {
  Future<String> requestOtp({required String phone});

  Future<AuthResponse> login({
    required String phone,
    required String otp,
    required String otpId,
  });

  Future<String> resendOtp({required String phone});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthResponse> login({
    required String phone,
    required String otp,
    required String otpId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (otp.length < 4) {
      throw Exception('Invalid OTP');
    }
    return AuthResponse(
      user: UserModel(
        id: 'captain-001',
        phone: phone,
      ),
    );
  }

  @override
  Future<String> requestOtp({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'otp_${phone.hashCode.abs()}';
  }

  @override
  Future<String> resendOtp({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'OTP resent';
  }
}
