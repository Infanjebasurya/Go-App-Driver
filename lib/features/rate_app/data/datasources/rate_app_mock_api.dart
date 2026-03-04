class RateAppMockApi {
  const RateAppMockApi();

  Future<void> submitReview({
    required int rating,
    required String feedback,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }
}
