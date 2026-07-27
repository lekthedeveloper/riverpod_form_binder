# riverpod_form_binder

[![pub package](https://img.shields.io/pub/v/riverpod_form_binder.svg)](https://pub.dev/packages/riverpod_form_binder)
[![Build Status](https://img.shields.io/github/actions/workflow/status/lekthedeveloper/riverpod_form_binder/ci.yml?branch=main)](https://github.com/lekthedeveloper/riverpod_form_binder)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)

A reactive form binding, state management, and debounced validation engine for **Riverpod 2.0** in Flutter applications.

---

## 🌟 Key Features

- ⚡ **Riverpod 2.0 Integration:** Built natively for `StateNotifier` / `Notifier` providers.
- 🎯 **Declarative Chainable Validation:** Fluent API for `required`, `email`, `minLength`, regex patterns, and custom sync rules.
- ⏳ **Debounced Async Validation:** Auto-debounces asynchronous server validation (e.g. username availability check).
- 🔍 **Field Lifecycle Tracking:** Tracks `isDirty`, `isTouched`, `isValidating`, `error`, and `value` per field.
- 🧪 **Testable:** Pure Dart state logic cleanly decoupled from Flutter UI code.

---

## 📦 Installation

Add `riverpod_form_binder` to your `pubspec.yaml`:

```yaml
dependencies:
  riverpod_form_binder: ^1.0.0
  flutter_riverpod: ^2.5.0
```

---

## 🚀 Quick Start

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_form_binder/riverpod_form_binder.dart';

class SignupFormNotifier extends FormBinderNotifier {
  SignupFormNotifier() {
    registerField<String>(
      'email',
      initialValue: '',
      validator: FieldValidator<String>()
          .required('Email is required')
          .email('Enter a valid email'),
    );
  }
}
```

---

## 📄 License

MIT License - Developed with ❤️ by [Olamilekan Adeyemi (@lekthedeveloper)](https://github.com/lekthedeveloper).
