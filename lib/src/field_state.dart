/// Immutable state representing a single form field in [riverpod_form_binder].
class FormFieldState<T> {
  /// Current field value.
  final T value;

  /// Validation error message if invalid, or null if valid.
  final String? error;

  /// Whether user has focused/blurred or interacted with this field.
  final bool isTouched;

  /// Whether the value has been modified from its initial state.
  final bool isDirty;

  /// Whether an asynchronous validation callback is currently running.
  final bool isValidating;

  const FormFieldState({
    required this.value,
    this.error,
    this.isTouched = false,
    this.isDirty = false,
    this.isValidating = false,
  });

  /// Whether the field is valid (no error and not currently running async validation).
  bool get isValid => error == null && !isValidating;

  /// Creates a copy of this state with updated parameters.
  FormFieldState<T> copyWith({
    T? value,
    String? Function()? error,
    bool? isTouched,
    bool? isDirty,
    bool? isValidating,
  }) {
    return FormFieldState<T>(
      value: value ?? this.value,
      error: error != null ? error() : this.error,
      isTouched: isTouched ?? this.isTouched,
      isDirty: isDirty ?? this.isDirty,
      isValidating: isValidating ?? this.isValidating,
    );
  }
}
