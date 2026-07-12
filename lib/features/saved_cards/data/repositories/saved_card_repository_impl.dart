import '../../../../core/auth/auth_token_provider.dart';
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
    required AuthTokenProvider authTokens,
    PublicBusinessCardRemoteDataSource? publicCardRemote,
  })  : _local = local,
        _remote = remote,
        _authTokens = authTokens,
        _publicCardRemote =
            publicCardRemote ?? PublicBusinessCardRemoteDataSourceImpl();

  final SavedCardLocalDataSource _local;
  final SavedCardRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;
  final PublicBusinessCardRemoteDataSource _publicCardRemote;

  Future<String?> _tryAccessToken() => _authTokens.tryAccessToken();

  Future<String> _requireAccessToken() => _authTokens.requireAccessToken();

  Future<void> _cacheCards(List<SavedCardModel> cards) async {
    await _local.replaceAll(cards);
  }

  SavedCardModel _mergeLocalFields(
    SavedCardModel remote,
    SavedCardModel? local,
  ) {
    if (local == null) return remote;
    return SavedCardModel(
      cardId: remote.cardId,
      origin: remote.origin,
      creationMethod: remote.creationMethod ?? local.creationMethod,
      displayName: remote.displayName,
      email: remote.email,
      phone: remote.phone,
      company: remote.company,
      title: remote.title,
      website: remote.website,
      linkedin: remote.linkedin,
      skills: remote.skills,
      school: remote.school,
      about: remote.about,
      note: remote.note ?? local.note,
      photoUrl: remote.photoUrl ?? local.photoUrl,
      accentColor: remote.accentColor ?? local.accentColor,
      backgroundColor: remote.backgroundColor ?? local.backgroundColor,
      savedAt: remote.savedAt,
      frontImagePath: local.frontImagePath ?? remote.frontImagePath,
      backImagePath: local.backImagePath ?? remote.backImagePath,
      isOwnerPremium: remote.isOwnerPremium,
      linkedEventGroupIds: remote.linkedEventGroupIds,
    );
  }

  @override
  Future<List<SavedCard>> getSavedCards() async {
    final token = await _tryAccessToken();
    if (token != null) {
      try {
        final remoteCards = await _remote.getSavedCards(accessToken: token);
        final localCards = await _local.getSavedCards();
        final localById = {
          for (final card in localCards) card.cardId: card,
        };
        final mergedCards = remoteCards
            .map(
                (remote) => _mergeLocalFields(remote, localById[remote.cardId]))
            .toList();
        await _cacheCards(mergedCards);
        return mergedCards.map((model) => model.toEntity()).toList();
      } on AuthApiException catch (e) {
        if (!e.isNetworkError) rethrow;
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
  Future<void> trackPublicContactClick({
    required String cardId,
    required String contactType,
  }) {
    return _publicCardRemote.trackContactClick(
      cardId: cardId,
      contactType: contactType,
    );
  }

  @override
  Future<SavedCard> addCard(SavedCard card) async {
    final token = await _requireAccessToken();
    final saved = await _remote.saveSavedCard(
      SavedCardModel.fromEntity(card).toJson(),
      accessToken: token,
    );
    final merged = saved.toEntity().copyWith(
          origin: card.origin,
          creationMethod:
              card.creationMethod ?? saved.toEntity().creationMethod,
          frontImagePath: card.frontImagePath,
          backImagePath: card.backImagePath,
          note: card.note,
        );
    await _local.saveCard(SavedCardModel.fromEntity(merged));
    return merged;
  }

  @override
  Future<void> saveCard(SavedCard card) async {
    final token = await _requireAccessToken();
    final updated = await _remote.updateSavedCard(
      SavedCardModel.fromEntity(card).toJson(),
      accessToken: token,
    );
    final merged = updated.toEntity().copyWith(
          origin: card.origin,
          frontImagePath: card.frontImagePath,
          backImagePath: card.backImagePath,
          note: updated.note ?? card.note,
        );
    await _local.saveCard(SavedCardModel.fromEntity(merged));
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
  Future<void> syncWalletPremium() async {
    final token = await _requireAccessToken();
    await _remote.upgradeWalletPlan(accessToken: token);
  }

  @override
  Future<void> cacheFromProfile(List<SavedCard> cards) async {
    await _local.replaceAll(
      cards.map(SavedCardModel.fromEntity).toList(growable: false),
    );
  }
}
