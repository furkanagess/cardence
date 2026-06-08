import '../entities/business_card.dart';

abstract class BusinessCardRepository {
  Future<List<BusinessCard>> getBusinessCards();
  Future<BusinessCard> saveCard(BusinessCard card);
}
