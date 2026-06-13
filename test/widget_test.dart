import 'package:flutter_test/flutter_test.dart';

import 'package:trainup/main.dart';

void main() {
  testWidgets('App shows TrainUp splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TrainUpApp());

    expect(find.text('TrainUp'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });
}
