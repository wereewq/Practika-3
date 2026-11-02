import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/genre_repository.dart';
import 'repositories/persistent_author_repository.dart';
import 'repositories/persistent_book_repository.dart';
import 'repositories/persistent_genre_repository.dart';
import 'repositories/persistent_publisher_repository.dart';
import 'repositories/persistent_reader_repository.dart';
import 'repositories/publisher_repository.dart';
import 'repositories/reader_repository.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/genre_list_notifier.dart';
import 'state/publisher_list_notifier.dart';
import 'state/reader_list_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  runApp(LibraryApp(prefs: prefs));
}

class LibraryApp extends StatelessWidget {
  final SharedPreferences prefs;

  const LibraryApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Инициализация постоянных репозиториев поверх localStorage
    final bookRepo = PersistentBookRepository(prefs);
    final authorRepo = PersistentAuthorRepository(prefs);
    final genreRepo = PersistentGenreRepository(prefs);
    final publisherRepo = PersistentPublisherRepository(prefs, bookRepo);
    final readerRepo = PersistentReaderRepository(prefs);

    return MultiProvider(
      providers: [
        Provider<BookRepository>.value(value: bookRepo),
        Provider<AuthorRepository>.value(value: authorRepo),
        Provider<GenreRepository>.value(value: genreRepo),
        Provider<PublisherRepository>.value(value: publisherRepo),
        Provider<ReaderRepository>.value(value: readerRepo),
        ChangeNotifierProvider<BookListNotifier>(
          create: (_) => BookListNotifier(bookRepo),
        ),
        ChangeNotifierProvider<AuthorListNotifier>(
          create: (_) => AuthorListNotifier(authorRepo),
        ),
        ChangeNotifierProvider<GenreListNotifier>(
          create: (_) => GenreListNotifier(genreRepo),
        ),
        ChangeNotifierProvider<PublisherListNotifier>(
          create: (_) => PublisherListNotifier(publisherRepo),
        ),
        ChangeNotifierProvider<ReaderListNotifier>(
          create: (_) => ReaderListNotifier(readerRepo),
        ),
      ],
      child: MaterialApp.router(
        title: 'Библиотечная система',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}