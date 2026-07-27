import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_form_binder/riverpod_form_binder.dart';

final loginFormNotifierProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, FormStateMap>((ref) {
  return LoginFormNotifier();
});

class LoginFormNotifier extends FormBinderNotifier {
  LoginFormNotifier() {
    registerField<String>(
      'email',
      initialValue: '',
      validator: FieldValidator<String>()
          .required('Email is required')
          .email('Enter a valid email address'),
    );

    registerField<String>(
      'password',
      initialValue: '',
      validator: FieldValidator<String>()
          .required('Password is required')
          .minLength(6, 'Password must be at least 6 characters'),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'riverpod_form_binder Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const LoginFormScreen(),
    );
  }
}

class LoginFormScreen extends ConsumerWidget {
  const LoginFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormNotifierProvider);
    final formNotifier = ref.read(loginFormNotifierProvider.notifier);

    final emailState = formState.get<String>('email');
    final passwordState = formState.get<String>('password');

    return Scaffold(
      appBar: AppBar(title: const Text('riverpod_form_binder Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailState?.isTouched == true ? emailState?.error : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => formNotifier.setFieldValue('email', val),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: passwordState?.isTouched == true ? passwordState?.error : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => formNotifier.setFieldValue('password', val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: formState.isValid
                  ? () async {
                      final ok = await formNotifier.validateAll();
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Form Submitted Successfully!')),
                        );
                      }
                    }
                  : null,
              child: const Text('Submit Login'),
            ),
          ],
        ),
      ),
    );
  }
}
