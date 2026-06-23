import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/store_config.dart';
import '../../domain/repositories/app_review_repository.dart';
import '../datasources/in_app_review_datasource.dart';

class AppReviewRepositoryImpl implements AppReviewRepository {
  AppReviewRepositoryImpl({InAppReviewDataSource? dataSource})
      : _dataSource = dataSource ?? InAppReviewDataSource();

  final InAppReviewDataSource _dataSource;

  @override
  Future<bool> requestReview() async {
    try {
      if (await _dataSource.isAvailable()) {
        await _dataSource.requestReview();
        return true;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS &&
          StoreConfig.iosAppStoreId != null) {
        await _dataSource.openStoreListing(
          appStoreId: StoreConfig.iosAppStoreId,
        );
        return true;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _dataSource.openStoreListing();
        return true;
      }

      return _openStoreListingWithUrlLauncher();
    } catch (_) {
      return _openStoreListingWithUrlLauncher();
    }
  }

  Future<bool> _openStoreListingWithUrlLauncher() async {
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? StoreConfig.appStoreListingUri()
        : StoreConfig.playStoreListingUri();
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
