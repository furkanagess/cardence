import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/business_card.dart';
import '../../domain/repositories/business_card_repository.dart';
import '../datasources/business_card_remote_datasource.dart';
import '../models/business_card_model.dart';

class BusinessCardRepositoryImpl implements BusinessCardRepository {
  BusinessCardRepositoryImpl({
    required BusinessCardRemoteDataSource remote,
    required AuthLocalDataSource authLocal,
  })  : _remote = remote,
        _authLocal = authLocal;

  final BusinessCardRemoteDataSource _remote;
  final AuthLocalDataSource _authLocal;

  Future<String> _requireAccessToken() async {
    final session = await _authLocal.getSession();
    if (session == null || session.accessToken.isEmpty) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return session.accessToken;
  }

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
