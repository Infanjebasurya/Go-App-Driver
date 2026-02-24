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

  String? validateIndiaMobile({
    required String rawInput,
    required String digits,
  }) {
    if (rawInput.isEmpty) {
      return 'Enter mobile number';
    }
    if (!RegExp(r'^[0-9]*$').hasMatch(rawInput)) {
      return 'Mobile Number should contain digits only';
    }
    if (digits.length > 10) {
      return 'Mobile Number should be 10 digits';
    }
    if (digits.isNotEmpty && !RegExp(r'^[6-9]').hasMatch(digits)) {
      return 'Please enter a valid Indian Mobile Number.';
    }
    if (digits.length != 10) {
      return 'Mobile Number should be 10 digits';
    }
    return null;
  }
}
