abstract interface class RateAppRepository {
  Future<void> submitReview({required int rating, required String feedback});
}
