import 'dart:async';

/// Function signature for synchronous validation rules.
typedef SyncValidator<T> = String? Function(T value);

/// Function signature for asynchronous validation rules.
typedef AsyncValidator<T> = Future<String?> Function(T value);

/// Declarative, chainable field validator builder.
class FieldValidator<T> {
  final List<SyncValidator<T>> _syncValidators = [];
  AsyncValidator<T>? _asyncValidator;

  FieldValidator<T> required([String message = 'This field is required']) {
    _syncValidators.add((value) {
      if (value == null) return message;
      if (value is String && value.trim().isEmpty) return message;
      if (value is Iterable && value.isEmpty) return message;
      return null;
    });
    return this;
  }

  FieldValidator<T> email([String message = 'Enter a valid email address']) {
    _syncValidators.add((value) {
      if (value == null || (value is String && value.isEmpty)) return null;
      if (value is String) {
        final emailRegex =
            RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
        if (!emailRegex.hasMatch(value)) return message;
      }
      return null;
    });
    return this;
  }

  FieldValidator<T> minLength(int length, [String? message]) {
    _syncValidators.add((value) {
      if (value == null) return null;
      if (value is String && value.length < length) {
        return message ?? 'Must be at least $length characters long';
      }
      return null;
    });
    return this;
  }

  FieldValidator<T> custom(SyncValidator<T> validator) {
    _syncValidators.add(validator);
    return this;
  }

  FieldValidator<T> customAsync(AsyncValidator<T> asyncValidator) {
    _asyncValidator = asyncValidator;
    return this;
  }

  /// Evaluates all synchronous validators against the provided value.
  String? validateSync(T value) {
    for (final validator in _syncValidators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Evaluates async validator if sync validation passed.
  Future<String?> validateAsync(T value) async {
    final syncError = validateSync(value);
    if (syncError != null) return syncError;

    if (_asyncValidator != null) {
      return await _asyncValidator!(value);
    }
    return null;
  }

  bool get hasAsyncValidator => _asyncValidator != null;
}
