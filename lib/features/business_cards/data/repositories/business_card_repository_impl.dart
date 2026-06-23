import '../../../../core/auth/auth_token_provider.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/business_card.dart';
import '../../domain/repositories/business_card_repository.dart';
import '../datasources/business_card_remote_datasource.dart';
import '../models/business_card_model.dart';

class BusinessCardRepositoryImpl implements BusinessCardRepository {
  BusinessCardRepositoryImpl({
    required BusinessCardRemoteDataSource remote,
    required AuthTokenProvider authTokens,
  })  : _remote = remote,
        _authTokens = authTokens;

  final BusinessCardRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;

  Future<String> _requireAccessToken() => _authTokens.requireAccessToken();

  @override
  Future<List<BusinessCard>> getBusinessCards() async {
    final token = await _requireAccessToken();
    final models = await _remote.getBusinessCards(accessToken: token);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<BusinessCard> saveCard(BusinessCard card) async {
    final token = await _requireAccessToken();
    final model = await _remote.saveBusinessCard(
      BusinessCardModel.fromEntity(card).toApiJson(),
      accessToken: token,
    );
    return model.toEntity();
  }

  @override
  Future<BusinessCard> upsertCard(BusinessCard card) async {
    final cardId = card.cardId?.trim();
    if (cardId == null || cardId.isEmpty) {
      throw AuthApiException('Kart kimliği eksik.');
    }

    final token = await _requireAccessToken();
    final body = BusinessCardModel.fromEntity(card).toApiJson();
    body['cardId'] = cardId;

    final model = await _remote.updateBusinessCard(
      body,
      accessToken: token,
    );
    return model.toEntity();
  }
}
