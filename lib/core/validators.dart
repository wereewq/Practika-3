export 'api_exceptions.dart' show ValidationException, CascadeDeleteException;

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

  /// Проверка на положительное число (> 0)
  static Validator positiveInteger([String message = 'Значение должно быть больше 0']) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final n = int.tryParse(value.trim());
      if (n == null || n <= 0) return message;
      return null;
    };
  }

  /// Формат адреса электронной почты
  static Validator email([String message = 'Некорректный адрес почты']) {
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return (value) => re.hasMatch(value?.trim() ?? '') ? null : message;
  }

  /// Формат телефонного номера
  static Validator phone([String message = 'Укажите телефон в формате +7XXXXXXXXXX']) {
    final re = RegExp(r'^\+?[0-9]{10,15}$');
    return (value) => re.hasMatch(value?.trim() ?? '') ? null : message;
  }

  /// Формат ISBN
  static Validator isbn([String message = 'Формат: 978-X-XXX-XXXXX-X']) {
    final re = RegExp(r'^(?:ISBN(?:-1[03])?:? )?(?=[-0-9 ]{13}$|[-0-9X ]{10}$\vert{}[0-9X]{10}$|[0-9]{13}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$');
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      return re.hasMatch(text) ? null : message;
    };
  }

  /// Комбинатор проверок
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
