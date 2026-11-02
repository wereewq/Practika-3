class ValidationException implements Exception {
  final Map<String, String> errors;
  const ValidationException(this.errors);

  @override
  String toString() => 'ValidationException: $errors';
}

class CascadeDeleteException implements Exception {
  final String message;
  final int count;
  const CascadeDeleteException(this.message, this.count);

  @override
  String toString() => message;
}

typedef Validator = String? Function(String?);

class V {
  /// Поле обязательно для заполнения
  static Validator required([String message = 'Поле обязательно для заполнения']) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }

  /// Длина строки в заданных пределах
  static Validator length({int min = 0, int max = 255}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.length < min) return 'Не короче $min символов';
      if (text.length > max) return 'Не длиннее $max символов';
      return null;
    };
  }

  /// Целое число в заданном диапазоне
  static Validator integer({int? min, int? max}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final n = int.tryParse(value.trim());
      if (n == null) return 'Введите целое число';
      if (min != null && n < min) return 'Значение не меньше $min';
      if (max != null && n > max) return 'Значение не больше $max';
      return null;
    };
  }

  /// Проверка на строго положительное целое число (> 0)
  static Validator positiveInteger([String message = 'Значение должно быть больше 0']) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final n = int.tryParse(value.trim());
      if (n == null || n <= 0) return message;
      return null;
    };
  }

  /// Проверка формата электронной почты
  static Validator email([String message = 'Некорректный адрес почты']) {
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return (value) => re.hasMatch(value?.trim() ?? '') ? null : message;
  }

  /// Проверка формата номера телефона
  static Validator phone([String message = 'Укажите телефон в формате +7XXXXXXXXXX']) {
    final re = RegExp(r'^\+?[0-9]{10,15}$');
    return (value) => re.hasMatch(value?.trim() ?? '') ? null : message;
  }

  /// Проверка ISBN-10 / ISBN-13
  static Validator isbn([String message = 'Формат: 978-X-XXX-XXXXX-X']) {
    final re = RegExp(r'^(?:ISBN(?:-1[03])?:? )?(?=[-0-9 ]{13}$|[-0-9X ]{10}$\vert{}[0-9X]{10}$|[0-9]{13}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$');
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      return re.hasMatch(text) ? null : message;
    };
  }

  /// Комбинатор проверок (возвращает текст первой найденной ошибки)
  static Validator combine(List<Validator> validators) {
    return (value) {
      for (final v in validators) {
        final error = v(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}