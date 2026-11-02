import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:books_store/core/api_client.dart';
import 'package:books_store/main.dart';

class _ImmediateMockAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final payload = jsonEncode({'items': [], 'page': 1, 'size': 10, 'total': 0});
    return ResponseBody.fromString(
      payload,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('Приложение запускается и инициализирует дерево провайдеров', (WidgetTester tester) async {
    final dio = buildDio();
    dio.httpClientAdapter = _ImmediateMockAdapter();

    await tester.pumpWidget(LibraryApp(dio: dio));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryApp), findsOneWidget);
  });
}
