import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:books_store/main.dart';

void main() {
  testWidgets('Библиотечное приложение запускается без ошибок', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(LibraryApp(prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryApp), findsOneWidget);
  });
}