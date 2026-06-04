import '../entities/card_share_payload.dart';
import '../entities/saved_card.dart';

extension CardSharePayloadToSavedCard on CardSharePayload {
  SavedCard toSavedCard() {
    return SavedCard(
      cardId: id,
      displayName: n,
      email: e,
      phone: p,
      company: c,
      title: t,
      website: w,
      linkedin: l,
      skills: s,
      school: o,
      about: h,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
