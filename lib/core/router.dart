import 'package:go_router/go_router.dart';

import '../models/author_query.dart';
import '../models/book_query.dart';
import '../models/genre_query.dart';
import '../models/publisher_query.dart';
import '../models/reader_query.dart';
import '../screens/author_detail_screen.dart';
import '../screens/author_form_screen.dart';
import '../screens/author_list_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_form_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/genre_detail_screen.dart';
import '../screens/genre_form_screen.dart';
import '../screens/genre_list_screen.dart';
import '../screens/publisher_detail_screen.dart';
import '../screens/publisher_form_screen.dart';
import '../screens/publisher_list_screen.dart';
import '../screens/reader_detail_screen.dart';
import '../screens/reader_form_screen.dart';
import '../screens/reader_list_screen.dart';
import '../widgets/adaptive_scaffold.dart';

BookQuery parseBookQuery(Map<String, String> params) {
  final sortParam = params['sort'] ?? 'title,asc';
  final sortParts = sortParam.split(',');
  final sortField = sortParts.first;
  final sortAscending = sortParts.length > 1 ? sortParts[1] != 'desc' : true;

  return BookQuery(
    search: params['search'] ?? '',
    genreId: int.tryParse(params['genreId'] ?? ''),
    publisherId: int.tryParse(params['publisherId'] ?? ''),
    yearFrom: int.tryParse(params['yearFrom'] ?? ''),
    yearTo: int.tryParse(params['yearTo'] ?? ''),
    sortField: sortField,
    sortAscending: sortAscending,
    page: int.tryParse(params['page'] ?? '') ?? 1,
    size: int.tryParse(params['size'] ?? '') ?? 10,
    includeDeleted: params['includeDeleted'] == 'true',
  );
}

Map<String, String> bookQueryToParams(BookQuery q) {
  final map = <String, String>{};
  if (q.search.isNotEmpty) map['search'] = q.search;
  if (q.genreId != null) map['genreId'] = q.genreId.toString();
  if (q.publisherId != null) map['publisherId'] = q.publisherId.toString();
  if (q.yearFrom != null) map['yearFrom'] = q.yearFrom.toString();
  if (q.yearTo != null) map['yearTo'] = q.yearTo.toString();
  map['sort'] = '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}';
  if (q.page > 1) map['page'] = q.page.toString();
  if (q.size != 10) map['size'] = q.size.toString();
  if (q.includeDeleted) map['includeDeleted'] = 'true';
  return map;
}

AuthorQuery parseAuthorQuery(Map<String, String> params) {
  final sortParam = params['sort'] ?? 'lastName,asc';
  final sortParts = sortParam.split(',');
  final sortField = sortParts.first;
  final sortAscending = sortParts.length > 1 ? sortParts[1] != 'desc' : true;

  return AuthorQuery(
    search: params['search'] ?? '',
    country: params['country'],
    sortField: sortField,
    sortAscending: sortAscending,
    page: int.tryParse(params['page'] ?? '') ?? 1,
    size: int.tryParse(params['size'] ?? '') ?? 10,
    includeDeleted: params['includeDeleted'] == 'true',
  );
}

Map<String, String> authorQueryToParams(AuthorQuery q) {
  final map = <String, String>{};
  if (q.search.isNotEmpty) map['search'] = q.search;
  if (q.country != null && q.country!.isNotEmpty) map['country'] = q.country!;
  map['sort'] = '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}';
  if (q.page > 1) map['page'] = q.page.toString();
  if (q.size != 10) map['size'] = q.size.toString();
  if (q.includeDeleted) map['includeDeleted'] = 'true';
  return map;
}

final appRouter = GoRouter(
  initialLocation: '/books',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final loc = state.uri.path;
        int idx = 0;
        if (loc.startsWith('/authors')) idx = 1;
        if (loc.startsWith('/genres')) idx = 2;
        if (loc.startsWith('/publishers')) idx = 3;
        if (loc.startsWith('/readers')) idx = 4;

        return AdaptiveScaffold(
          currentIndex: idx,
          child: child,
        );
      },
      routes: [
        // Книги
        GoRoute(
          path: '/books',
          builder: (context, state) =>
              BookListScreen(initialQuery: parseBookQuery(state.uri.queryParameters)),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const BookFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => BookDetailScreen(
                bookId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => BookFormScreen(
                    id: int.tryParse(state.pathParameters['id'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Авторы
        GoRoute(
          path: '/authors',
          builder: (context, state) =>
              AuthorListScreen(initialQuery: parseAuthorQuery(state.uri.queryParameters)),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const AuthorFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => AuthorDetailScreen(
                authorId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => AuthorFormScreen(
                    id: int.tryParse(state.pathParameters['id'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Жанры
        GoRoute(
          path: '/genres',
          builder: (context, state) => const GenreListScreen(initialQuery: GenreQuery()),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const GenreFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => GenreDetailScreen(
                genreId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => GenreFormScreen(
                    id: int.tryParse(state.pathParameters['id'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Издательства
        GoRoute(
          path: '/publishers',
          builder: (context, state) =>
              const PublisherListScreen(initialQuery: PublisherQuery()),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const PublisherFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => PublisherDetailScreen(
                publisherId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => PublisherFormScreen(
                    id: int.tryParse(state.pathParameters['id'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Читатели
        GoRoute(
          path: '/readers',
          builder: (context, state) => const ReaderListScreen(initialQuery: ReaderQuery()),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const ReaderFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => ReaderDetailScreen(
                readerId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => ReaderFormScreen(
                    id: int.tryParse(state.pathParameters['id'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);