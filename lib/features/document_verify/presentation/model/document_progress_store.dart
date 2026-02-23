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

  static bool isCompleted(DocumentType type) => _completed[type] ?? false;

  static void setCompleted(DocumentType type, bool completed) {
    _completed[type] = completed;
  }

  static void reset() {
    _completed.updateAll((_, _) => false);
  }
}
