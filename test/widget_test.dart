import 'package:flutter_test/flutter_test.dart';
import 'package:taman_kata_ajaib_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TamanKataAjaibApp());
    expect(find.text('PETUALANGAN TAMAN KATA AJAIB'), findsOneWidget);
  });
}
