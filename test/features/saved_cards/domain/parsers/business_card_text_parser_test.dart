import 'package:cardence/features/saved_cards/domain/parsers/business_card_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('places typical Turkish business card fields', () {
    final draft = BusinessCardTextParser.parse(
      frontText: '''
AYŞE YILMAZ
Senior Product Manager
Cardence Yazılım A.Ş.
E-mail: ayse.yilmaz@cardence.app
Tel: +90 532 111 22 33
www.cardence.app
linkedin.com/in/ayseyilmaz
Kadıköy İstanbul
''',
      backText: '''
Ürün stratejisi ve büyüme odaklı ekiplerle çalışırım.
Flutter, Dart, Figma, Product Discovery
''',
    );

    expect(draft.displayName, 'AYŞE YILMAZ');
    expect(draft.title, 'Senior Product Manager');
    expect(draft.company, 'Cardence Yazılım A.Ş.');
    expect(draft.email, 'ayse.yilmaz@cardence.app');
    expect(draft.phone, contains('532'));
    expect(draft.website, 'https://www.cardence.app');
    expect(draft.linkedin, contains('linkedin.com/in/ayseyilmaz'));
    expect(draft.about, contains('Ürün stratejisi'));
    expect(draft.skills, contains('Flutter'));
  });

  test('does not put address into name or company', () {
    final draft = BusinessCardTextParser.parse(
      frontText: '''
Mehmet Demir
Yazılım Mühendisi
Acme Teknoloji Ltd. Şti.
mehmet@acme.com
Atatürk Cad. No:12 İstanbul
''',
    );

    expect(draft.displayName, 'Mehmet Demir');
    expect(draft.title, 'Yazılım Mühendisi');
    expect(draft.company, contains('Acme'));
    expect(draft.displayName, isNot(contains('Cad')));
  });
}
