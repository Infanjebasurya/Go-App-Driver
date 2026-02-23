enum DocumentStatus { verified, pending, rejected, notUploaded }

class DocumentModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconAsset;
  final DocumentStatus status;
  final String? frontImagePath;
  final String? backImagePath;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.status,
    this.frontImagePath,
    this.backImagePath,
  });

  DocumentModel copyWith({
    DocumentStatus? status,
    String? frontImagePath,
    String? backImagePath,
  }) {
    return DocumentModel(
      id: id,
      title: title,
      subtitle: subtitle,
      iconAsset: iconAsset,
      status: status ?? this.status,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
    );
  }
}
