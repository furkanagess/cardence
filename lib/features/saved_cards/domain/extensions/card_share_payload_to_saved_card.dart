import '../entities/card_creation_method.dart';
import '../entities/card_share_payload.dart';
import '../entities/saved_card.dart';
import '../entities/saved_card_origin.dart';

extension CardSharePayloadToSavedCard on CardSharePayload {
  SavedCard toSavedCard() {
    return SavedCard(
      cardId: id,
      origin: SavedCardOrigin.cardence,
      creationMethod: CardCreationMethod.cardenceLink,
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
      photoUrl: ph,
      accentColor: tc,
      backgroundColor: bc,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
