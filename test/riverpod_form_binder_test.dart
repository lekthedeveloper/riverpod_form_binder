import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_form_binder/riverpod_form_binder.dart';

void main() {
  group('FieldValidator Tests', () {
    test('required validator should evaluate empty values', () {
      final validator = FieldValidator<String>().required('Required field');
      expect(validator.validateSync(''), equals('Required field'));
      expect(validator.validateSync('hello'), isNull);
    });

    test('email validator should validate email patterns', () {
      final validator = FieldValidator<String>().email('Invalid email');
      expect(validator.validateSync('invalid-email'), equals('Invalid email'));
      expect(validator.validateSync('test@example.com'), isNull);
    });

    test('minLength validator should check string length', () {
      final validator = FieldValidator<String>().minLength(6);
      expect(validator.validateSync('short'), equals('Must be at least 6 characters long'));
      expect(validator.validateSync('longenough'), isNull);
    });
  });

  group('FormBinderNotifier Tests', () {
    test('registerField should initialize field state', () {
      final notifier = FormBinderNotifier();
      notifier.registerField<String>(
        'email',
        initialValue: '',
        validator: FieldValidator<String>().required('Required'),
      );

      final state = notifier.state.get<String>('email');
      expect(state, isNotNull);
      expect(state?.value, equals(''));
      expect(state?.error, equals('Required'));
      expect(notifier.state.isValid, isFalse);
    });

    test('setFieldValue should update value and clear sync error when valid', () {
      final notifier = FormBinderNotifier();
      notifier.registerField<String>(
        'email',
        initialValue: '',
        validator: FieldValidator<String>().email('Invalid email'),
      );

      notifier.setFieldValue('email', 'user@domain.com');
      final state = notifier.state.get<String>('email');

      expect(state?.value, equals('user@domain.com'));
      expect(state?.error, isNull);
      expect(state?.isDirty, isTrue);
      expect(notifier.state.isValid, isTrue);
    });
  });
}
