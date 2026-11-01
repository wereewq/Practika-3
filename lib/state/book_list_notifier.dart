import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import '../repositories/book_repository.dart';

enum LoadStatus { idle, loading, success, error }

class BookListNotifier extends ChangeNotifier {
  final BookRepository _repository;
  bool _disposed = false;

  BookListNotifier(this._repository);

  BookQuery _query = const BookQuery();
  PageResult<Book> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  BookQuery get query => _query;
  PageResult<Book> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;
  bool get isAllSelected =>
      _result.items.isNotEmpty &&
      _result.items.every((b) => _selected.contains(b.id));

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _safeNotify();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить книги: $e';
      _status = LoadStatus.error;
    }
    _safeNotify();
  }

  Future<void> applyQuery(BookQuery next) async {
    _query = next;
    _selected.clear(); // Сброс выделения при смене фильтрации/страницы
    await load();
  }

  void toggleSelection(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    _safeNotify();
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      _selected.clear();
    } else {
      for (final book in _result.items) {
        _selected.add(book.id);
      }
    }
    _safeNotify();
  }

  void clearSelection() {
    _selected.clear();
    _safeNotify();
  }

  // Мягкое удаление выбранных записей
  Future<void> deleteSelected() async {
    if (_selected.isEmpty) return;
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  // Одиночное мягкое удаление
  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    _selected.remove(id);
    await load();
  }

  // Физическое удаление записи
  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    _selected.remove(id);
    await load();
  }

  // Восстановление записи
  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }

  // Переключение видимости удалённых книг
  Future<void> toggleIncludeDeleted(bool value) async {
    await applyQuery(_query.copyWith(includeDeleted: value));
  }
}