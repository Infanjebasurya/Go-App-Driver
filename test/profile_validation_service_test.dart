import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/profile/domain/services/profile_validation_service.dart';

void main() {
  group('ProfileValidationService', () {
    final service = ProfileValidationService();

    test('validateName accepts a valid full name', () {
      expect(service.validateName('Yogesh Kumar'), isNull);
    });

    test('validateName rejects invalid name characters', () {
      expect(service.validateName('Yogesh@123'), isNotNull);
    });

    test('validateGender accepts only known values', () {
      expect(service.validateGender('Male'), isNull);
      expect(service.validateGender('Unknown'), isNotNull);
    });

    test('validateDob rejects future and underage dates', () {
      final now = DateTime.now();
      final futureDob = '1 January ${now.year + 1}';
      final underAgeDob = '1 January ${now.year - 10}';

      expect(service.validateDob(futureDob), isNotNull);
      expect(service.validateDob(underAgeDob), isNotNull);
    });

    test('validateDob accepts adult valid date', () {
      expect(service.validateDob('12 July 1995'), isNull);
    });

    test('validateEmergencyContact allows empty and validates format', () {
      expect(service.validateEmergencyContact(''), isNull);
      expect(service.validateEmergencyContact('9876543210'), isNull);
      expect(service.validateEmergencyContact('12345'), isNotNull);
      expect(service.validateEmergencyContact('1111111111'), isNotNull);
      expect(service.validateEmergencyContact('2345678901'), isNotNull);
    });
  });
}
