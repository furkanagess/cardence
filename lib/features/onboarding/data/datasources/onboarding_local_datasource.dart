import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_card_draft_model.dart';

const String _keyOnboardingCompleted = 'onboarding_completed';
const String _keyDraftCard = 'onboarding_draft_card';
const String _keyDraftCards = 'onboarding_draft_cards';

/// Onboarding tamamlanma durumunu ve kart taslağını yerel olarak saklar.
/// Çoklu kart: [_keyDraftCards] listesi; yoksa eski tek kart [_keyDraftCard] migrate edilir.
abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
  Future<void> saveDraftCard(OnboardingCardDraftModel draft);
  Future<OnboardingCardDraftModel?> getDraftCard();
  Future<List<OnboardingCardDraftModel>> getDraftCards();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  Future<List<OnboardingCardDraftModel>> _getList() async {
    final jsonStr = _prefs.getString(_keyDraftCards);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list
            .map((e) => OnboardingCardDraftModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    final single = _prefs.getString(_keyDraftCard);
    if (single != null && single.isNotEmpty) {
      final model = OnboardingCardDraftModel.fromJsonString(single);
      if (model != null) {
        await _prefs.setString(_keyDraftCards, jsonEncode([model.toJson()]));
        return [model];
      }
    }
    return [];
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
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
    await _prefs.setString(_keyDraftCards, jsonEncode(list.map((e) => e.toJson()).toList()));
    await _prefs.setString(_keyDraftCard, draft.toJsonString());
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
}
