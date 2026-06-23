import '../repositories/app_review_repository.dart';

class RequestAppReview {
  const RequestAppReview(this._repository);

  final AppReviewRepository _repository;

  Future<bool> call() => _repository.requestReview();
}
