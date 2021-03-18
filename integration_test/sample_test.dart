import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// test_driverなくても動くけど。。。
// https://github.com/flutter/flutter/issues/72063#issuecomment-742528902

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("2 + 2 = 4", (WidgetTester tester) async {
    expect(2 + 2, equals(4));
  });
}
