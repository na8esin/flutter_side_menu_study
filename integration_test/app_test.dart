// Imports the Flutter Driver API.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_practice/sample/default_sample_main.dart' as app;

// https://flutter.dev/docs/testing/integration-tests#migrating-from-flutter_driver
//   を見て変更

void main() {
  // https://github.com/flutter/flutter/issues/72063#issuecomment-753384244
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('end-to-end test', () {
    setUpAll(() async {});

    testWidgets('tap on the floating action button; verify counter',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');

      // Emulate a tap on the floating action button.
      await tester.tap(fab);

      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });
}
