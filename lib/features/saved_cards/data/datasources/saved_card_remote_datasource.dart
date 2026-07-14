import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/saved_card_model.dart';
import '../models/wallet_card_invitation_model.dart';
import '../models/wallet_quota_model.dart';

abstract class SavedCardRemoteDataSource {
  Future<List<SavedCardModel>> getSavedCards({required String accessToken});

  Future<SavedCardModel> saveSavedCard(
    Map<String, dynamic> body, {
    required String accessToken,
  });

  Future<SavedCardModel> updateSavedCard(
    Map<String, dynamic> body, {
    required String accessToken,
  });

  Future<WalletQuotaModel> getWalletQuota({required String accessToken});

  Future<WalletQuotaModel> upgradeWalletPlan({required String accessToken});

  Future<void> deleteSavedCard({
    required String cardId,
    required String accessToken,
  });

  Future<List<WalletCardInvitationModel>> getPendingInvitations({
    required String accessToken,
  });

  Future<void> acceptInvitation({
    required String invitationId,
    required String accessToken,
  });

  Future<void> rejectInvitation({
    required String invitationId,
    required String accessToken,
  });
}

class SavedCardRemoteDataSourceImpl implements SavedCardRemoteDataSource {
  SavedCardRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  List<SavedCardModel> _parseCardList(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'];
    if (data is! List) {
      throw AuthApiException('Kayıtlı kartlar alınamadı.');
    }

    return data
        .map((item) => SavedCardModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  SavedCardModel _parseCard(Map<String, dynamic> json) {
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Kart bilgisi alınamadı.');
    }
    return SavedCardModel.fromJson(data);
  }

  WalletQuotaModel _parseQuota(Map<String, dynamic> json) {
    final data = ApiResponseParser.readMap(json['data'] ?? json['Data']);
    if (data == null) {
      throw AuthApiException('Cüzdan kotası alınamadı.');
    }
    return WalletQuotaModel.fromJson(data);
  }

  @override
  Future<List<SavedCardModel>> getSavedCards({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/SavedCards',
      accessToken: accessToken,
      fallbackError: 'Kayıtlı kartlar alınamadı.',
    );
    return _parseCardList(json);
  }

  @override
  Future<SavedCardModel> saveSavedCard(
    Map<String, dynamic> body, {
    required String accessToken,
  }) async {
    final json = await _client.post(
      '/SaveSavedCard',
      body: body,
      accessToken: accessToken,
      fallbackError: 'Kart cüzdana eklenemedi.',
    );
    return _parseCard(json);
  }

  @override
  Future<SavedCardModel> updateSavedCard(
    Map<String, dynamic> body, {
    required String accessToken,
  }) async {
    final json = await _client.put(
      '/UpdateSavedCard',
      body: body,
      accessToken: accessToken,
      fallbackError: 'Kart güncellenemedi.',
    );
    return _parseCard(json);
  }

  @override
  Future<WalletQuotaModel> getWalletQuota({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/WalletQuota',
      accessToken: accessToken,
      fallbackError: 'Cüzdan kotası alınamadı.',
    );
    return _parseQuota(json);
  }

  @override
  Future<WalletQuotaModel> upgradeWalletPlan({
    required String accessToken,
  }) async {
    final json = await _client.post(
      '/UpgradeWalletPlan',
      accessToken: accessToken,
      fallbackError: 'Premium cüzdan etkinleştirilemedi.',
    );
    return _parseQuota(json);
  }

  @override
  Future<void> deleteSavedCard({
    required String cardId,
    required String accessToken,
  }) async {
    await _client.delete(
      '/DeleteSavedCard?cardId=${Uri.encodeQueryComponent(cardId)}',
      accessToken: accessToken,
      fallbackError: 'Kart silinemedi.',
    );
  }

  List<WalletCardInvitationModel> _parseInvitationList(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] ?? json['Data'];
    if (data is! List) {
      throw AuthApiException('Kart ekleme davetleri alınamadı.');
    }

    return data
        .map(
          (item) => WalletCardInvitationModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<WalletCardInvitationModel>> getPendingInvitations({
    required String accessToken,
  }) async {
    final json = await _client.get(
      '/WalletCardInvitations',
      accessToken: accessToken,
      fallbackError: 'Kart ekleme davetleri alınamadı.',
    );
    return _parseInvitationList(json);
  }

  @override
  Future<void> acceptInvitation({
    required String invitationId,
    required String accessToken,
  }) async {
    await _client.post(
      '/AcceptWalletCardInvitation',
      body: {'id': invitationId},
      accessToken: accessToken,
      fallbackError: 'Davet kabul edilemedi.',
      requireData: false,
    );
  }

  @override
  Future<void> rejectInvitation({
    required String invitationId,
    required String accessToken,
  }) async {
    await _client.post(
      '/RejectWalletCardInvitation',
      body: {'id': invitationId},
      accessToken: accessToken,
      fallbackError: 'Davet reddedilemedi.',
      requireData: false,
    );
  }
}
