import '../../domain/entities/onboarding_card_draft.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../models/onboarding_card_draft_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  @override
  Future<bool> isOnboardingCompleted() =>
      _localDataSource.isOnboardingCompleted();

  @override
  Future<void> setOnboardingCompleted() =>
      _localDataSource.setOnboardingCompleted();

  @override
  Future<void> clearOnboardingCompleted() =>
      _localDataSource.clearOnboardingCompleted();

  @override
  Future<void> saveDraftCard(OnboardingCardDraft draft) async {
    await _localDataSource.saveDraftCard(
      OnboardingCardDraftModel.fromEntity(draft),
    );
  }

  @override
  Future<OnboardingCardDraft?> getDraftCard() async {
    final model = await _localDataSource.getDraftCard();
    return model?.toEntity().withStandardFrontFields();
  }

  @override
  Future<List<OnboardingCardDraft>> getDraftCards() async {
    final models = await _localDataSource.getDraftCards();
    return models.map((m) => m.toEntity().withStandardFrontFields()).toList();
  }
}
