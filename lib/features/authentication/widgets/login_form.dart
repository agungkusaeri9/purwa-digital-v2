import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm(
      {super.key,
      required this.emailController,
      required this.passwordController,
      required this.onSubmit,
      required this.isLoading});
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Column(children: [
        TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 12),
        TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 24),
        FilledButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Masuk')),
      ]);
}
