import 'package:go_router/go_router.dart';
import '../models/author_query.dart';
import '../models/book_query.dart';
import '../screens/author_detail_screen.dart';
import '../screens/author_list_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
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
        final currentIndex = loc.startsWith('/authors') ? 1 : 0;
        return AdaptiveScaffold(
          currentIndex: currentIndex,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/books',
          builder: (context, state) {
            final query = parseBookQuery(state.uri.queryParameters);
            return BookListScreen(initialQuery: query);
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return BookDetailScreen(bookId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/authors',
          builder: (context, state) {
            final query = parseAuthorQuery(state.uri.queryParameters);
            return AuthorListScreen(initialQuery: query);
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return AuthorDetailScreen(authorId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);