import 'document_model.dart';

class DocumentProgressStore {
  DocumentProgressStore._();

  static final Map<DocumentType, bool> _completed = {
    DocumentType.drivingLicense: false,
    DocumentType.vehicleRC: false,
    DocumentType.aadhaarCard: false,
    DocumentType.panCard: false,
    DocumentType.bankDetails: false,
  };

  static final Map<DocumentType, String?> _frontImagePath = {
    DocumentType.drivingLicense: null,
    DocumentType.vehicleRC: null,
    DocumentType.aadhaarCard: null,
    DocumentType.panCard: null,
    DocumentType.bankDetails: null,
  };

  static final Map<DocumentType, String?> _backImagePath = {
    DocumentType.drivingLicense: null,
    DocumentType.vehicleRC: null,
    DocumentType.aadhaarCard: null,
    DocumentType.panCard: null,
    DocumentType.bankDetails: null,
  };

  static bool isCompleted(DocumentType type) => _completed[type] ?? false;

  static void setCompleted(DocumentType type, bool completed) {
    _completed[type] = completed;
  }

  static String? frontImagePath(DocumentType type) => _frontImagePath[type];

  static String? backImagePath(DocumentType type) => _backImagePath[type];

  static void setFrontImagePath(DocumentType type, String? path) {
    _frontImagePath[type] = path;
  }

  static void setBackImagePath(DocumentType type, String? path) {
    _backImagePath[type] = path;
  }

  static void reset() {
    _completed.updateAll((_, _) => false);
    _frontImagePath.updateAll((_, _) => null);
    _backImagePath.updateAll((_, _) => null);
  }
}
