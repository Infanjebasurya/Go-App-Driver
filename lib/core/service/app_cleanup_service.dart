import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/features/document_verify/presentation/model/document_progress_store.dart';
import 'package:goapp/features/documents/presentation/services/document_upload_file_service.dart';

class AppCleanupService {
  AppCleanupService({required DocumentUploadFileService fileService})
      : _fileService = fileService;

  final DocumentUploadFileService _fileService;

  static const List<String> _kycDraftKeys = <String>[
    'profile.photo.path',
    'bank_details.account_holder',
    'bank_details.bank_name',
    'bank_details.account_number',
    'bank_details.confirm_account_number',
    'bank_details.ifsc',
  ];

  Future<void> clearKycDraftsAndSensitiveFiles() async {
    await _fileService.clearManagedUploadsDirectory();
    DocumentProgressStore.reset();
    for (final key in _kycDraftKeys) {
      await TextFieldStore.remove(key);
    }
  }
}
