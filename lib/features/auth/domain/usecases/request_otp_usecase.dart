import 'package:dartz/dartz.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/auth/domain/repositories/auth_repository.dart';

class RequestOtpUseCase {
  const RequestOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String>> call({required String phone}) {
    return _repository.requestOtp(phone: phone);
  }
}
