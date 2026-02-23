enum DocumentStatus { verified, pending, rejected, notUploaded }

class DocumentModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconAsset;
  final DocumentStatus status;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.status,
  });

  DocumentModel copyWith({DocumentStatus? status}) {
    return DocumentModel(
      id: id,
      title: title,
      subtitle: subtitle,
      iconAsset: iconAsset,
      status: status ?? this.status,
    );
  }
}
