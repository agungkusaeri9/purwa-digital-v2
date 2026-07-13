import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/login_view_model.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginViewModelProvider, (_, next) {
      if (next.isSuccess) {
        context.go('/home');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });
    final state = ref.watch(loginViewModelProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('Masuk')),
        body: Padding(
            padding: const EdgeInsets.all(24),
            child: LoginForm(
                emailController: _email,
                passwordController: _password,
                isLoading: state.isSubmitting,
                onSubmit: () => ref
                    .read(loginViewModelProvider.notifier)
                    .submit(
                        email: _email.text.trim(), password: _password.text))));
  }
}
