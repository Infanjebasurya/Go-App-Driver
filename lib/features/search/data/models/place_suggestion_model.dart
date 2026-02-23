class PlaceSuggestionModel {
  const PlaceSuggestionModel({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return PlaceSuggestionModel(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structured?['main_text'] as String?,
      secondaryText: structured?['secondary_text'] as String?,
    );
  }
}
