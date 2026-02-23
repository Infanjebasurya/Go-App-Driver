class PhoneNumberService {
  String normalizeDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String? toE164India(String digits) {
    if (digits.length != 10) {
      return null;
    }
    return '+91$digits';
  }

  String? validateIndiaMobile(String digits) {
    if (digits.isEmpty) {
      return 'Enter mobile number';
    }
    if (digits.length != 10) {
      return 'Enter valid 10-digit mobile number';
    }
    return null;
  }
}
