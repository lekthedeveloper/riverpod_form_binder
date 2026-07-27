import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'field_state.dart';
import 'field_validator.dart';

/// Form state map container.
class FormStateMap {
  final Map<String, FormFieldState<dynamic>> fields;

  const FormStateMap(this.fields);

  /// Returns field state for key.
  FormFieldState<T>? get<T>(String key) {
    final state = fields[key];
    if (state is FormFieldState<T>) return state;
    return null;
  }

  /// Whether all fields in the form map are valid.
  bool get isValid => fields.values.every((f) => f.isValid);

  /// Whether any field is currently running async validation.
  bool get isValidating => fields.values.any((f) => f.isValidating);

  /// Whether any field in the form has been modified.
  bool get isDirty => fields.values.any((f) => f.isDirty);
}

/// Base Riverpod [StateNotifier] or [Notifier] engine for managing form fields.
class FormBinderNotifier extends StateNotifier<FormStateMap> {
  final Map<String, FieldValidator<dynamic>> _validators = {};
  final Map<String, Timer?> _debounceTimers = {};
  final Duration asyncDebounceDuration;

  FormBinderNotifier({
    this.asyncDebounceDuration = const Duration(milliseconds: 400),
  }) : super(const FormStateMap({}));

  /// Registers a form field with key, initial value, and optional validator.
  void registerField<T>(
    String key, {
    required T initialValue,
    FieldValidator<T>? validator,
  }) {
    if (validator != null) {
      _validators[key] = validator;
    }

    final initialError = validator?.validateSync(initialValue);

    final newFields = Map<String, FormFieldState<dynamic>>.from(state.fields);
    newFields[key] = FormFieldState<T>(
      value: initialValue,
      error: initialError,
      isDirty: false,
      isTouched: false,
    );
    state = FormStateMap(newFields);
  }

  /// Updates the value of a registered field and triggers revalidation.
  void setFieldValue<T>(String key, T newValue) {
    final current = state.get<T>(key);
    if (current == null) return;

    final validator = _validators[key] as FieldValidator<T>?;
    final syncError = validator?.validateSync(newValue);

    final newFields = Map<String, FormFieldState<dynamic>>.from(state.fields);
    newFields[key] = current.copyWith(
      value: newValue,
      error: () => syncError,
      isDirty: true,
      isValidating: validator?.hasAsyncValidator ?? false,
    );
    state = FormStateMap(newFields);

    if (validator != null && validator.hasAsyncValidator && syncError == null) {
      _debounceTimers[key]?.cancel();
      _debounceTimers[key] = Timer(asyncDebounceDuration, () async {
        final asyncError = await validator.validateAsync(newValue);
        final latestCurrent = state.get<T>(key);
        if (latestCurrent != null && latestCurrent.value == newValue) {
          final updatedFields =
              Map<String, FormFieldState<dynamic>>.from(state.fields);
          updatedFields[key] = latestCurrent.copyWith(
            error: () => asyncError,
            isValidating: false,
          );
          state = FormStateMap(updatedFields);
        }
      });
    }
  }

  /// Marks a field as touched (e.g. on focus lost / blur).
  void markFieldTouched(String key) {
    final current = state.fields[key];
    if (current == null) return;

    final newFields = Map<String, FormFieldState<dynamic>>.from(state.fields);
    newFields[key] = current.copyWith(isTouched: true);
    state = FormStateMap(newFields);
  }

  /// Validates all fields in the form. Returns true if completely valid.
  Future<bool> validateAll() async {
    final newFields = Map<String, FormFieldState<dynamic>>.from(state.fields);
    bool allValid = true;

    for (final entry in state.fields.entries) {
      final key = entry.key;
      final current = entry.value;
      final validator = _validators[key];

      if (validator != null) {
        final error = await validator.validateAsync(current.value);
        newFields[key] = current.copyWith(
          error: () => error,
          isTouched: true,
        );
        if (error != null) allValid = false;
      }
    }

    state = FormStateMap(newFields);
    return allValid && !state.isValidating;
  }

  /// Resets all fields to non-touched and clean state.
  void reset() {
    final newFields = Map<String, FormFieldState<dynamic>>.from(state.fields);
    for (final key in newFields.keys) {
      final current = newFields[key]!;
      newFields[key] = current.copyWith(
        isTouched: false,
        isDirty: false,
      );
    }
    state = FormStateMap(newFields);
  }

  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }
}
