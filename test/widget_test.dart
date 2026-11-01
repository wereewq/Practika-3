import 'package:flutter_test/flutter_test.dart';
import 'package:books_store/main.dart';

void main() {
  testWidgets('Библиотечное приложение запускается без ошибок', (WidgetTester tester) async {
    await tester.pumpWidget(const LibraryApp());
    await tester.pumpAndSettle();
    expect(find.byType(LibraryApp), findsOneWidget);
  });
}
