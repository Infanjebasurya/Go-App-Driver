import '../model/document_upload_model.dart';

class DocumentNumberRules {
  const DocumentNumberRules._();

  static String normalize(DocumentStep step, String value) {
    switch (step) {
      case DocumentStep.profilePhoto:
        return value.trim();
      case DocumentStep.drivingLicense:
      case DocumentStep.vehicleRC:
        return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      case DocumentStep.identityAadhaar:
        return value.replaceAll(RegExp(r'[^0-9]'), '');
      case DocumentStep.identityPan:
        return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      case DocumentStep.bankAccount:
        return value.trim();
    }
  }

  static String? validate(DocumentStep step, String value) {
    switch (step) {
      case DocumentStep.profilePhoto:
        return null;
      case DocumentStep.drivingLicense:
        if (!RegExp(r'^[A-Z]{2}\d{2}\d{4}\d{7}$').hasMatch(value)) {
          return 'Enter valid license number (e.g. MH1220180012345)';
        }
        return null;
      case DocumentStep.vehicleRC:
        if (!RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{0,3}[0-9]{4}$').hasMatch(value)) {
          return 'Enter valid vehicle number (e.g. TN01AB1234)';
        }
        return null;
      case DocumentStep.identityAadhaar:
        if (!RegExp(r'^\d{12}$').hasMatch(value)) {
          return 'Aadhaar number must be 12 digits';
        }
        return null;
      case DocumentStep.identityPan:
        if (!RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(value)) {
          return 'Enter valid PAN (e.g. ABCDE1234F)';
        }
        return null;
      case DocumentStep.bankAccount:
        return null;
    }
  }
}
