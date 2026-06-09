import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../models/onboarding_card_draft_model.dart';

const String _legacyKeyOnboardingCompleted = 'onboarding_completed';
const String _legacyKeyDraftCard = 'onboarding_draft_card';
const String _legacyKeyDraftCards = 'onboarding_draft_cards';

String onboardingCompletedStorageKey(String userId) =>
    'onboarding_completed_$userId';
String onboardingDraftCardsStorageKey(String userId) =>
    'onboarding_draft_cards_$userId';
String onboardingDraftCardStorageKey(String userId) =>
    'onboarding_draft_card_$userId';

/// Onboarding tamamlanma durumunu ve kart taslağını kullanıcıya özel saklar.
abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
  Future<void> clearOnboardingCompleted();
  Future<void> saveDraftCard(OnboardingCardDraftModel draft);
  Future<OnboardingCardDraftModel?> getDraftCard();
  Future<List<OnboardingCardDraftModel>> getDraftCards();
  Future<void> replaceAllDraftCards(List<OnboardingCardDraftModel> drafts);
  Future<void> clearForUser(String userId);
  Future<void> clearLegacyKeys();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl(this._prefs, this._authLocal);

  final SharedPreferences _prefs;
  final AuthLocalDataSource _authLocal;

  Future<String?> _userId() async {
    final session = await _authLocal.getSession();
    final userId = session?.userId;
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  Future<String> _completedKey() async {
    final userId = await _userId();
    if (userId == null) return '${_legacyKeyOnboardingCompleted}_guest';
    return onboardingCompletedStorageKey(userId);
  }

  Future<String> _draftCardsKey() async {
    final userId = await _userId();
    if (userId == null) return '${_legacyKeyDraftCards}_guest';
    return onboardingDraftCardsStorageKey(userId);
  }

  Future<String> _draftCardKey() async {
    final userId = await _userId();
    if (userId == null) return '${_legacyKeyDraftCard}_guest';
    return onboardingDraftCardStorageKey(userId);
  }

  Future<void> _migrateLegacyIfNeeded(String userId) async {
    final cardsKey = onboardingDraftCardsStorageKey(userId);
    final existing = _prefs.getString(cardsKey);
    if (existing != null && existing.isNotEmpty) return;

    final legacyCards = _prefs.getString(_legacyKeyDraftCards);
    if (legacyCards != null && legacyCards.isNotEmpty) {
      await _prefs.setString(cardsKey, legacyCards);
      await _prefs.remove(_legacyKeyDraftCards);
    } else {
      final legacySingle = _prefs.getString(_legacyKeyDraftCard);
      if (legacySingle != null && legacySingle.isNotEmpty) {
        await _prefs.setString(cardsKey, jsonEncode([jsonDecode(legacySingle)]));
        await _prefs.remove(_legacyKeyDraftCard);
      }
    }

    final completedKey = onboardingCompletedStorageKey(userId);
    if (_prefs.getBool(completedKey) == null) {
      final legacyCompleted = _prefs.getBool(_legacyKeyOnboardingCompleted);
      if (legacyCompleted == true) {
        await _prefs.setBool(completedKey, true);
        await _prefs.remove(_legacyKeyOnboardingCompleted);
      }
    }
  }

  Future<List<OnboardingCardDraftModel>> _getList() async {
    final userId = await _userId();
    if (userId != null) {
      await _migrateLegacyIfNeeded(userId);
    }

    final jsonStr = _prefs.getString(await _draftCardsKey());
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list
            .map((e) =>
                OnboardingCardDraftModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final single = _prefs.getString(await _draftCardKey());
    if (single != null && single.isNotEmpty) {
      final model = OnboardingCardDraftModel.fromJsonString(single);
      if (model != null) {
        await _prefs.setString(
          await _draftCardsKey(),
          jsonEncode([model.toJson()]),
        );
        return [model];
      }
    }
    return [];
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final userId = await _userId();
    if (userId != null) {
      await _migrateLegacyIfNeeded(userId);
    }
    return _prefs.getBool(await _completedKey()) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(await _completedKey(), true);
  }

  @override
  Future<void> clearOnboardingCompleted() async {
    await _prefs.remove(await _completedKey());
  }

  @override
  Future<void> saveDraftCard(OnboardingCardDraftModel draft) async {
    final list = await _getList();
    final id = draft.cardId;
    final index = list.indexWhere((c) => c.cardId == id);
    if (index >= 0) {
      list[index] = draft;
    } else {
      list.add(draft);
    }
    await _prefs.setString(
      await _draftCardsKey(),
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    await _prefs.setString(await _draftCardKey(), draft.toJsonString());
  }

  @override
  Future<OnboardingCardDraftModel?> getDraftCard() async {
    final list = await _getList();
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<List<OnboardingCardDraftModel>> getDraftCards() async {
    return _getList();
  }

  @override
  Future<void> replaceAllDraftCards(
    List<OnboardingCardDraftModel> drafts,
  ) async {
    await _prefs.setString(
      await _draftCardsKey(),
      jsonEncode(drafts.map((e) => e.toJson()).toList()),
    );
    if (drafts.isNotEmpty) {
      await _prefs.setString(await _draftCardKey(), drafts.first.toJsonString());
    } else {
      await _prefs.remove(await _draftCardKey());
    }
  }

  @override
  Future<void> clearForUser(String userId) async {
    await _prefs.remove(onboardingCompletedStorageKey(userId));
    await _prefs.remove(onboardingDraftCardsStorageKey(userId));
    await _prefs.remove(onboardingDraftCardStorageKey(userId));
  }

  @override
  Future<void> clearLegacyKeys() async {
    await _prefs.remove(_legacyKeyOnboardingCompleted);
    await _prefs.remove(_legacyKeyDraftCard);
    await _prefs.remove(_legacyKeyDraftCards);
    await _prefs.remove('${_legacyKeyOnboardingCompleted}_guest');
    await _prefs.remove('${_legacyKeyDraftCard}_guest');
    await _prefs.remove('${_legacyKeyDraftCards}_guest');
  }
}
