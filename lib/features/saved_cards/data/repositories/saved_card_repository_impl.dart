import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/repositories/saved_card_repository.dart';
import '../../domain/extensions/card_share_payload_to_saved_card.dart';
import '../datasources/public_business_card_remote_datasource.dart';
import '../datasources/saved_card_local_datasource.dart';
import '../datasources/saved_card_remote_datasource.dart';
import '../models/saved_card_model.dart';

class SavedCardRepositoryImpl implements SavedCardRepository {
  SavedCardRepositoryImpl({
    required SavedCardLocalDataSource local,
    required SavedCardRemoteDataSource remote,
    required AuthLocalDataSource authLocal,
    PublicBusinessCardRemoteDataSource? publicCardRemote,
  })  : _local = local,
        _remote = remote,
        _authLocal = authLocal,
        _publicCardRemote =
            publicCardRemote ?? PublicBusinessCardRemoteDataSourceImpl();

  final SavedCardLocalDataSource _local;
  final SavedCardRemoteDataSource _remote;
  final AuthLocalDataSource _authLocal;
  final PublicBusinessCardRemoteDataSource _publicCardRemote;

  Future<String?> _tryAccessToken() async {
    final session = await _authLocal.getSession();
    if (session == null || session.accessToken.isEmpty) return null;
    return session.accessToken;
  }

  Future<String> _requireAccessToken() async {
    final token = await _tryAccessToken();
    if (token == null) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return token;
  }

  Future<void> _cacheCards(List<SavedCardModel> cards) async {
    await _local.replaceAll(cards);
  }

  @override
  Future<List<SavedCard>> getSavedCards() async {
    final token = await _tryAccessToken();
    if (token != null) {
      try {
        final remoteCards = await _remote.getSavedCards(accessToken: token);
        await _cacheCards(remoteCards);
        return remoteCards.map((model) => model.toEntity()).toList();
      } on AuthApiException {
        rethrow;
      } catch (_) {
        // Sunucu erişilemezse yerel önbelleğe düş.
      }
    }

    final localCards = await _local.getSavedCards();
    return localCards.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SavedCard?> fetchPublicCardByCardId(String cardId) async {
    final payload = await _publicCardRemote.fetchSharePayload(cardId);
    return payload?.toSavedCard();
  }

  @override
  Future<SavedCard> addCard(SavedCard card) async {
    final token = await _requireAccessToken();
    final saved = await _remote.saveSavedCard(
      SavedCardModel.fromEntity(card).toJson(),
      accessToken: token,
    );
    await _local.saveCard(saved);
    return saved.toEntity();
  }

  @override
  Future<void> saveCard(SavedCard card) async {
    final token = await _requireAccessToken();
    final updated = await _remote.updateSavedCard(
      SavedCardModel.fromEntity(card).toJson(),
      accessToken: token,
    );
    await _local.saveCard(updated);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final token = await _requireAccessToken();
    await _remote.deleteSavedCard(cardId: cardId, accessToken: token);
    await _local.deleteCard(cardId);
  }

  @override
  Future<SavedCardsWalletQuota> getWalletQuota() async {
    final token = await _requireAccessToken();
    final quota = await _remote.getWalletQuota(accessToken: token);
    return quota.toEntity();
  }

  @override
  Future<void> cacheFromProfile(List<SavedCard> cards) async {
    await _local.replaceAll(
      cards.map(SavedCardModel.fromEntity).toList(growable: false),
    );
  }
}
