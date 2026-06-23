import 'package:in_app_review/in_app_review.dart';

class InAppReviewDataSource {
  final InAppReview _inAppReview = InAppReview.instance;

  Future<bool> isAvailable() => _inAppReview.isAvailable();

  Future<void> requestReview() => _inAppReview.requestReview();

  Future<void> openStoreListing({String? appStoreId}) =>
      _inAppReview.openStoreListing(appStoreId: appStoreId);
}
